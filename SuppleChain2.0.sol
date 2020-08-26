// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5;


contract SuppleChain {
    event addNewCompany(address addr, string name, string info);
    event addNewVoucher(uint id, address signedBy, uint totalAmount, uint signedDate);
    event addNewTicket(uint id, uint amount, uint voucherId);
    event transferTicket(uint id, uint amount, address _from, address _to);
    event destroyVoucher(uint id);
    event destroyTicket(uint id);
    
    // company
    struct Company {
        address addr;  // company's signed up address
        string name;
        string info;
        uint[] voucherList;  // the vouchers signed by this company
        uint[] ticketList;  // the ticket owned by this company
    }
    
    // voucher
    struct Voucher {
        uint id;
        address signedBy;  // the address of the core company who signed this voucher
        uint totalAmount;
        uint signedDate;
        uint dueDate;  // the core company would not like to cash it before the due date
        uint destroyDate;  // the date when this voucher will be destroy without cash it
        uint interest;  // the interest will be paid by the core company when this voucher is due
        uint[] ticketList;  // contains the id of tickets which belongs to this voucher
    }
    
    struct Ticket {
        uint id;
        uint amount;
        uint voucherId;  // this ticket is belongs to which voucherId
        address[] transferHistory;  // contains the transfer history of this ticket by the company's address
        uint[] transferDate;
        // address owner;  // owner can be tracked by the last one of the transferHistory
    }
    
    mapping(address => Company) companyMap;
    mapping(uint => Voucher) voucherMap;
    mapping(uint => Ticket) ticketMap;
    // it should be visiable whether a company is a core company, a bank or neither.
    mapping(address => bool) public isCoreCompany;
    mapping(address => bool) public isBank;
    
    address host;
    uint internal voucherIdCounter = 0;
    uint internal ticketIdCounter = 0;
    function getVoucherIdCounter() internal returns (uint) {
        voucherIdCounter++;
        return voucherIdCounter;
    }
    function getTicketIdCounter() internal returns (uint) {
        ticketIdCounter++;
        return ticketIdCounter;
    }
    
    constructor() public {
        host = msg.sender;
    }
    
    // the one who wants to sign up should send the message by itself.
    function addCompany(string calldata _name, string calldata _info) external {
        Company storage c = companyMap[msg.sender];
        require(c.addr == address(0), "this company is exit!");
        c.addr = msg.sender;
        c.name = _name;
        c.info = _info;
        emit addNewCompany(c.addr, c.name, c.info);
    }
    
    // only the host and the bank has the right to assign a core company
    function addCoreCompany(address _addr) external {
        require(msg.sender == host || isBank[msg.sender], "you are not the host or a bank, no rights");
        Company storage c = companyMap[_addr];
        require(c.addr != address(0), "the address you are adding is not a company yet.");
        isCoreCompany[_addr] = true;
    }
    
    // only the host of the contract and the core company has the right to assign a bank.
    function addBank(address _addr) external {
        require(msg.sender == host|| isCoreCompany[msg.sender], "you are not the host or a core company, no rights");
        Company storage c = companyMap[_addr];
        require(c.addr != address(0), "the address you are adding is not a company yet.");
        isBank[_addr] = true;
    }
    
    function getCompany(address _addr) external view returns (string memory name, string memory info) {
        require(companyMap[_addr].addr != address(0), "not a company yet.");
        name = companyMap[_addr].name;
        info = companyMap[_addr].info;
    }
    function getVoucherById(uint _id) public view returns (
        uint _amount, 
        address _signedBy, 
        uint _interest, 
        uint _signedDate, 
        uint _dueDate, 
        uint _destroyDate
        ) {
            
        Voucher storage v = voucherMap[_id];
        require(v.id != 0, "this voucher does not exist!");
        _amount = v.totalAmount;
        _signedBy = v.signedBy;
        _interest = v.interest;
        _signedDate = v.signedDate;
        _dueDate = v.dueDate;
        _destroyDate = v.destroyDate;
    }
    function getTicketsByVoucher(uint _id) public view returns (uint[] memory _ticketList) {
        Voucher storage v = voucherMap[_id];
        require(v.id != 0, "this voucher does not exist!");
        _ticketList = v.ticketList;
    }
    // todo : only the voucher or the ticket's owner can see the ticket information
    function getTicketById(uint _id) public view returns (uint _amount, uint _voucherId) {
        Ticket storage t = ticketMap[_id];
        require(t.id != 0, "this ticket does not exist!");
        _amount = t.amount;
        _voucherId = t.voucherId;
    }
    function getTicketHistory(uint _id) external view returns(address[] memory  _transferHistory, uint[] memory _transferDate) {
        Ticket storage t = ticketMap[_id];
        require(t.id != 0, "this ticket does not exist!");
        _transferHistory = t.transferHistory;
        _transferDate = t.transferDate;
    }
    
    function getMyTickets() public view returns (uint[] memory) {
        require(
            companyMap[msg.sender].addr != address(0),
            "you should be a company before owning a ticket."
            );
        return companyMap[msg.sender].ticketList;
    }
    function getMyVouchers() public view returns (uint[] memory) {
        require(
            companyMap[msg.sender].addr != address(0) && isCoreCompany[msg.sender], 
            "you should be a core company before owning a voucher."
            );
        return companyMap[msg.sender].voucherList;
    }
    
    function signAndTransfer(uint _amount, address _transferTo, 
        uint _dueDate, uint _destroyDate, uint _interest) external 
        returns (uint, uint) {
        
        //     checking
        // check if it is a core company
        require(isCoreCompany[msg.sender], "only a core company can sign voucher.");
        // check if the _dueDate and _destroyDate is valid with signDate
        require(_dueDate > now, "due date is unvalid.");
        require(_destroyDate > _dueDate, "destroy date is unvalid.");
        // check if _interest > 0  and _amount > 0
        require(_interest >= 0, "interest rate is less than 0.");
        require(_amount > 0, "the voucher amount should be greater than 0.");
        // check if _transferTo is a company
        require(
            companyMap[_transferTo].addr != address(0),
            "the address _transferTo should be a company."
        );
        
        // new a voucher and add it to the company
        uint voucherId = getVoucherIdCounter();
        voucherMap[voucherId].id = voucherId;
        voucherMap[voucherId].signedBy = msg.sender;
        voucherMap[voucherId].totalAmount = _amount;
        voucherMap[voucherId].signedDate = block.timestamp;
        voucherMap[voucherId].dueDate = _dueDate;
        voucherMap[voucherId].destroyDate = _destroyDate;
        voucherMap[voucherId].interest = _interest;
        emit addNewVoucher(voucherId, msg.sender, _amount, block.timestamp);
        
        // new a ticket
        uint ticketId = getTicketIdCounter();
        ticketMap[ticketId].id = ticketId;
        ticketMap[ticketId].amount = _amount;
        ticketMap[ticketId].voucherId = voucherId;
        ticketMap[ticketId].transferHistory.push(_transferTo);
        ticketMap[ticketId].transferDate.push(block.timestamp);
        emit addNewTicket(ticketId, _amount, voucherId);
        emit transferTicket(ticketId, _amount, msg.sender, _transferTo);
        
        // add the ticket to the owner
        companyMap[_transferTo].ticketList.push(ticketId);
        
        // add the ticket to the voucher
        voucherMap[voucherId].ticketList.push(ticketId);
        
        // add the voucher to the signer (core company)
        companyMap[msg.sender].voucherList.push(voucherId);
        
        return (voucherId, ticketId);
    }
    
    function divideAndTransfer(
        uint _id,  // ticket id
        uint _amount,  // transfer amount
        address _to  // transfer to
    ) external returns (uint ticketId) {
        
        Ticket storage t = ticketMap[_id];
        
        //    checking
        require(t.id != 0, "this ticket does not exist!");
        require(t.amount >= _amount, "this ticket does not have enough amount!");
        uint len = t.transferHistory.length;
        require(t.transferHistory[len - 1] == msg.sender, "you do not own this ticket");
        require(companyMap[_to].addr != address(0), "the company transfer to is not exist!");
        
        // if the amount of the ticket is equal to the transfer amount
        if (ticketMap[_id].amount == _amount) {
            // add transferHistory
            ticketMap[_id].transferHistory.push(_to);
            ticketMap[_id].transferDate.push(now);
            
            // change the ownership inside two companys
            //   1. delete the ownership of the msg.sender 
            uint[] storage tickets = companyMap[msg.sender].ticketList;  // this is a references and not a independent copy
            uint i;
            for (i = 0; i < tickets.length; i++) {
                if (tickets[i] == _id) {
                    break;
                }
            }
            tickets[i] = tickets[tickets.length - 1];
            tickets.pop();
            //   2. add the ownership of the reciever
            companyMap[_to].ticketList.push(_id);
            
            // for return
            ticketId = _id;
            emit transferTicket(ticketId, _amount, msg.sender, _to);
        } else {
            // new a ticket
            ticketId = getTicketIdCounter();
            ticketMap[ticketId].id = ticketId;
            ticketMap[ticketId].amount = _amount;
            uint voucherId = ticketMap[_id].voucherId;
            ticketMap[ticketId].voucherId = voucherId;
            for (uint i = 0; i < ticketMap[_id].transferHistory.length; i++) {
                ticketMap[ticketId].transferHistory.push(ticketMap[_id].transferHistory[i]);
            }
            ticketMap[ticketId].transferHistory.push(_to);
            for (uint i = 0; i < ticketMap[_id].transferDate.length; i++) {
                ticketMap[ticketId].transferDate.push(ticketMap[_id].transferDate[i]);
            }
            ticketMap[ticketId].transferDate.push(block.timestamp);
            emit addNewTicket(ticketId, _amount, voucherId);
            emit transferTicket(ticketId, _amount, msg.sender, _to);
            
            // add the new ticket to the company's ticketList
            companyMap[_to].ticketList.push(ticketId);
            
            // add the new ticket to the voucher's ticketList
            voucherMap[voucherId].ticketList.push(ticketId);
            
            // delete the original ticket amount.
            ticketMap[_id].amount -= _amount;
            
            
        }
    }
    
    function writeOffByTicket(uint _id) public {
        Ticket storage t = ticketMap[_id];
        
        // checking
        require(t.id != 0, "this ticket does not exist!");
        uint len = t.transferHistory.length;
        address owner = t.transferHistory[len - 1];
        require(owner == msg.sender, "you do not own this ticket");
        require(isBank[msg.sender], "only Bank can write off tickets.");
        // require(voucherMap[t.voucherId].dueDate <= block.timestamp, "this ticket is not due yet.");
        
        // delete from voucher
        uint[] storage ticketList = voucherMap[t.voucherId].ticketList;
        uint i;
        for (i = 0; i < ticketList.length; i++) {
            if (ticketList[i] == _id) {
                break;
            }
        }
        ticketList[i] = ticketList[ticketList.length - 1];
        ticketList.pop();
        
        // delete from owner
        ticketList = companyMap[owner].ticketList;
        for (i = 0; i < ticketList.length; i++) {
            if (ticketList[i] == _id) {
                break;
            }
        }
        ticketList[i] = ticketList[ticketList.length - 1];
        ticketList.pop();
        
        // delete the data in ticket
        emit destroyTicket(t.id);
        t.id = 0;
        t.amount = 0;
        Voucher storage v = voucherMap[t.voucherId];
        t.voucherId = 0;
        delete t.transferDate;
        delete t.transferHistory;
        
        // if the voucher has no ticket, it should be delete
        if (v.ticketList.length == 0) {
            uint[] storage voucherList = companyMap[v.signedBy].voucherList;
            for (i = 0; i < voucherList.length; i++) {
                if (voucherList[i] == v.id) {
                    break;
                }
            }
            voucherList[i] = voucherList[voucherList.length - 1];
            voucherList.pop();
            
            emit destroyVoucher(v.id);
            v.id = 0;
            v.signedBy = address(0);
            v.totalAmount = 0;
            v.signedDate = 0;
            v.dueDate = 0;
            v.destroyDate = 0;
            v.interest = 0;
            delete v.ticketList;
        }
    }
    
    function writeOffByVoucher(uint _id) external {
        Voucher storage v = voucherMap[_id];
        require(v.id != 0, "this voucher does not exist or wirteOff already!");
        require(isBank[msg.sender], "only Bank can write off vouchers.");
        // require(voucherMap[t.voucherId].dueDate <= block.timestamp, "this ticket is not due yet.");
        
        uint len = v.ticketList.length;
        for (uint i = 0; i < len; i++) {
            writeOffByTicket(v.ticketList[0]);
        }
        // the delete of voucher itself is automate done by writeOffByTicket
    }
}