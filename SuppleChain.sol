// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5 <0.6.0;

contract  SuppleChain {
    enum Actor{ CoreCompany, Company, FundSuppler}
    enum Phase{ Transfer, Destory}
    
    struct User{
        address addr;
        bytes32 name;
        Actor actor;
    }
    
    struct Ticket {
        bytes32 ticketID;  // ID may change when transfer
        bytes32 token;  // the token is given when it is signed and not changeable after
        uint signedTime;
        address signedBy;
        uint[] timestamps;
        address[] transferHistory;
        uint amount;
        address owner;
        Phase finished;
    }  // todolist: valid date
    
    mapping(address => bool) coreCompanyMap;
    mapping(address => User) companyMap;
    mapping(address => bool) fundSupplerMap;
    mapping(bytes32 => Ticket) ticketMap;
    mapping(bytes32 => bool) tokenMap;
    
    address contractOwner;
    
    constructor() public {
        contractOwner = msg.sender;
    }
    
    // a new company sign up to the system by itself
    function newCompany(bytes32 name) external returns(bool, bytes32) {
        User storage user = companyMap[msg.sender]; // how to delete if it is unvalid?
        
        // if(user.addr != address(0)){
        //     return (false, "this address has been occupied!");  // error?
        // }
        require(user.addr != address(0));
        user.addr = msg.sender;
        user.name = name;
        user.actor = Actor.Company;
        return (true, "Success");
    }
    
    // the core company should sign up as a regular company then added as core company by the constructer of the contract
    function addCoreCompany(address addr) external returns(bool, bytes32) {
        
        if (msg.sender != contractOwner) {
            return (false, "you are not the constructer");
            // the core company should be added by the constructer of the contract
        }
        if (companyMap[addr].addr == address(0)) {
            return (false, "this company does not exist!");
        }
        coreCompanyMap[addr] = true;
        companyMap[addr].actor = Actor.CoreCompany;
        return (true, "Success");
    }
    
    // the FundSuppler should sign up as a regular company then added as FundSuppler by the core company.
    function addFundSuppler(address addr) external returns(bool, bytes32) {
        
        if (!coreCompanyMap[msg.sender]) {
            return (false, "you are not the CoreCompany!"); // FundSuppler should be add by the CoreCompany
        }
        if (companyMap[addr].addr == address(0)) {
            return (false, "this company does not exist!");
        }
        fundSupplerMap[addr] = true;
        companyMap[addr].actor = Actor.FundSuppler;
        return (true, "Success");
    }
    
    // the CoreCompany sign the tickets but not sended, return the ticketID
    function signTicket(bytes32 ticketID, bytes32 token, uint timestamp) external returns(bool, bytes32, bytes32) {
         Ticket storage ticket = ticketMap[ticketID];
         if (coreCompanyMap[msg.sender] != true) {
             return (false, 0x0, "you are not core company!");
         }
         if (ticket.ticketID != 0x0) {
             return (false, 0x0, "the ticketID already exist!");
         }
         if (tokenMap[token] == true) {
             return (false, 0x0, "the token already exist!");
         }
         tokenMap[token] = true;
         User memory user = companyMap[msg.sender];
         ticket.ticketID = ticketID;
         ticket.token = token;
         ticket.signedTime = timestamp;
         ticket.signedBy = user.addr;
         ticket.owner = msg.sender;
         ticket.finished = Phase.Transfer;
         return (true, ticket.ticketID, "Success!");
    }
    
    // the msg.sendet send the ticket to the reciever, return the ticketID which the reciever gets
    // todolist : try to generate a newTicketID with callin parameter.
    function transferTicket(bytes32 ticketID, uint timestamp, uint amount, address reciever, bytes32 newTicketID) external returns(bool, bytes32, bytes32) {
        Ticket memory ticket = ticketMap[ticketID];
        if(ticket.ticketID == 0x0) {
            return (false, "the ticketID don't exist!", 0x0);
        }
        User memory user = companyMap[msg.sender];
        if (user.addr == address(0)) {
            return (false, "the send company don't exist!", 0x0);
        }
        User memory re = companyMap[reciever];
        if (re.addr == address(0)) {
            return (false, "the recieve company don't exist!", 0x0);
        }
        if (ticket.owner != msg.sender) {
            return (false, "you don't own this ticket!", 0x0);
        }
        if (amount > ticket.amount) {
            return (false, "ticket don't have enough amount!", 0x0);
        }
        else if (amount == ticket.amount) {
            ticketMap[ticketID].timestamps.push(timestamp);
            ticketMap[ticketID].transferHistory.push(re.addr);
            ticketMap[ticketID].owner = reciever;
            newTicketID = ticketID;
            return (true, "Success!", newTicketID);
        }
        else {
            Ticket storage newTicket = ticketMap[newTicketID];
            if (newTicket.ticketID != 0x0) {
                return (false, "the newTicketID already exist!", 0x0);
            }
            ticket.amount -= amount;
            newTicket.amount = amount;
            newTicket.timestamps.push(timestamp);
            newTicket.transferHistory.push(re.addr);
            newTicket.owner = reciever;
            return (true, "Success!", newTicketID);
        }
    }
    
    // the owner of the contract, the owner of the ticket, the CoreCompany, the FundSuppler can get the whole message of the ticket
    function getTicket(bytes32 ticketID) view external returns(bool, bytes32,
        bytes32 token,
        uint signedTime,
        address signedBy,
        uint[] memory timestamps,
        address[] memory transferHistory,
        uint amount,
        address owner,
        Phase finished
    ) {
        Ticket memory ticket = ticketMap[ticketID];
        if(ticket.ticketID == 0x0) {
            return (false, "the ticketID don't exist!", token, signedTime, signedBy, timestamps, transferHistory, amount, owner, finished);
        }
        if (msg.sender != ticket.owner && coreCompanyMap[msg.sender] && fundSupplerMap[msg.sender] && contractOwner != msg.sender) {
            return (false, "you have no access!", token, signedTime, signedBy, timestamps, transferHistory, amount, owner, finished);
        }
        return (true, "Success!",  ticket.token, ticket.signedTime, ticket.signedBy, ticket.timestamps, 
        ticket.transferHistory, ticket.amount, ticket.owner, ticket.finished);
    }
    
    function writeOff(bytes32 ticketID) external returns(bool, bytes32) {
        if (!fundSupplerMap[msg.sender]) {
            return (false, "you have no access to write off!");
        }
        Ticket memory ticket = ticketMap[ticketID];
        if(ticket.ticketID == 0x0) {
            return (false, "the ticketID don't exist!");
        }
        if (ticket.owner != msg.sender) {
            return (false, "you do not own this ticket!");
        }
        ticketMap[ticketID].finished = Phase.Transfer;
        return (true, "Success!");
    }
    
    function getCompany(address addr) view external returns(bool, bytes32, bytes32 _name, Actor _actor) {
        if (companyMap[addr].addr == address(0)) {
            return (false, "this company does not exist!", _name, _actor);
        }
        User memory company = companyMap[addr];
        return (true, "Success!", company.name, company.actor);
    }

}
