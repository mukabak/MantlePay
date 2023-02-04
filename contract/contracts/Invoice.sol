// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Invoice {
    enum Status {
        PENDING,
        PAID,
        CLOSED,
        DECLINED
    }

    struct InvoiceStruct {
        address payable creator;
        address recipient;
        uint256 amount;
        string comment;
        Status status;
        uint256 createdAt;
        uint256 updatedAt;
    }

    mapping(uint256 => InvoiceStruct) public invoices;
    uint256 nextInvoiceId;

    // ============= Events =============

    event InvoiceCreated(uint256 invoiceId, address creator, address recipient);
    event InvoiceUpdated(
        uint256 invoiceId,
        address creator,
        address recipient,
        Status status
    );

    // ============ Modifiers ============

    modifier OnlyRecipient(uint256 _invoiceId) {
        InvoiceStruct storage invoice = invoices[_invoiceId];
        require(
            invoice.recipient == msg.sender,
            "Can only be called by the recipient."
        );
        _;
    }

    modifier OnlyCreator(uint256 _invoiceId) {
        InvoiceStruct storage _invoice = invoices[_invoiceId];
        require(
            _invoice.creator == msg.sender,
            "Can only be called by the creator."
        );
        _;
    }

    modifier OnlyPendingInvoice(uint256 _invoiceId) {
        InvoiceStruct storage _invoice = invoices[_invoiceId];
        require(_invoice.status == Status.PENDING, "Invoice is not open.");
        _;
    }

    modifier AfterUpdate(uint256 _invoiceId) {
        _;
        InvoiceStruct storage _invoice = invoices[_invoiceId];
        _triggerUpdate(_invoice);
        emit InvoiceUpdated(
            _invoiceId,
            _invoice.creator,
            _invoice.recipient,
            _invoice.status
        );
    }

    // ============ Functions ============

    function createInvoice(uint256 _amount, string calldata _comment) public {
        _createInvoice(payable(msg.sender), address(0), _amount, _comment);
    }

    function createInvoice(
        address _recipient,
        uint256 _amount,
        string calldata _comment
    ) public {
        _createInvoice(payable(msg.sender), _recipient, _amount, _comment);
    }

    function payInvoice(
        uint256 _invoiceId
    ) public payable OnlyPendingInvoice(_invoiceId) AfterUpdate(_invoiceId) {
        InvoiceStruct storage _invoice = invoices[_invoiceId];
        require(msg.value >= _invoice.amount, "Insufficient funds.");
        _invoice.creator.transfer(_invoice.amount);
        _invoice.status = Status.PAID;
    }

    function closeInvoice(
        uint256 _invoiceId
    )
        public
        OnlyCreator(_invoiceId)
        OnlyPendingInvoice(_invoiceId)
        AfterUpdate(_invoiceId)
    {
        InvoiceStruct storage _invoice = invoices[_invoiceId];
        _invoice.status = Status.CLOSED;
    }

    function declineInvoice(
        uint256 _invoiceId
    )
        public
        OnlyRecipient(_invoiceId)
        OnlyPendingInvoice(_invoiceId)
        AfterUpdate(_invoiceId)
    {
        InvoiceStruct storage _invoice = invoices[_invoiceId];
        _invoice.status = Status.DECLINED;
    }

    function getInvoicesByCreator(
        address creator
    ) public view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](nextInvoiceId);
        uint256 count = 0;
        for (uint256 i = 0; i < nextInvoiceId; i++) {
            if (invoices[i].creator == creator) {
                ids[count] = i;
                count++;
            }
        }
        return ids;
    }

    function getInvoicesByRecipient(
        address recipient
    ) public view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](nextInvoiceId);
        uint256 count = 0;
        for (uint256 i = 0; i < nextInvoiceId; i++) {
            if (invoices[i].recipient == recipient) {
                ids[count] = i;
                count++;
            }
        }
        return ids;
    }

    function _createInvoice(
        address _creator,
        address _recipient,
        uint256 _amount,
        string calldata _comment
    ) private {
        invoices[nextInvoiceId] = InvoiceStruct(
            payable(_creator),
            _recipient,
            _amount,
            _comment,
            Status.PENDING,
            block.timestamp,
            block.timestamp
        );
        emit InvoiceCreated(nextInvoiceId, _creator, _recipient);
        nextInvoiceId++;
    }

    function _triggerUpdate(InvoiceStruct storage _invoice) private {
        _invoice.updatedAt = block.timestamp;
        _invoice.createdAt = block.timestamp;
    }
}
