# SuppleChain
supple chain on unpay tickets, the blockchain summer school project in ZJU.


## SuppleChain2.0说明文档

1. 相对于原来的智能合约，不再局限于链上一次只能存在一张凭证。可以同时存在多家核心企业，同时签发多家凭证。采用了voucher和ticket两级的数据结构，其中voucher为核心企业签发的一张凭证的总体信息，一张voucher可以对应多张ticket，voucher持有于签发的核心企业手中，可以查看voucher下的所有ticket。ticket持有在凭证持有人手中，并可以进行转发，转发过程由于分拆可能生成新的ticket，但是新的ticket会挂在原来的voucher名下。因此，所有ticket都可以根据所属的voucher查到，又所有voucher都可以被所签发的公司所查，因此该签发公司可以查看由于自己签发的voucher所产生的ticket的所有流转。

2. 添加了事件event

3. 函数说明
  isCoreCompany 可以查看输入公司（地址）是否是核心企业
  isBank 可以查看是否是银行
  addCompany（name，info） 为自己注册当前公司，其中info信息为待定，请自行添加。另外需要注意，程序不要求公司名唯一，不提供根据公司名查找对应公司
  addCoreCompany 将输入公司（地址）设为核心企业，要求发送者为合约部署者或者银行，要求输入公司已经注册
  addBank 将输入公司设为银行，要求发送者为合约部署者或者银行，要求输入公司已经注册
  getCompany 获取公司信息
  getVoucherById 获取voucher信息
      由于将凭证分成voucher和ticket两层来管理，所以ticket的共性信息都会存储在voucher中，比如谁注册的，这张voucher的总额，利率interest，签发日期 signDate，到期日期 dueDate，销毁日期destroyDate（利率，到期日期，销毁日期都是根据贷款的要求填的，这是现实的需求，该模型后面还可以继续扩展，比如银行限定核心企业的签发数，要求在dueDate之后才能核销贷款，过了destroyDate可以让核心企业自动核销等。
  getTicketsByVoucher通过voucher的ID获取该voucher下所有现存的ticket
  getTicketHistory 获得当前ticket的流转历史
  getMyTickets getMyVouchers 获得发送者名下的ticket或voucher
  signAndTransfer 签发一步到位
  divideAndTransfer 这个其实就是transfer，就是转发
  writeOffByTicket 根据ticket的ID进行核销，若该ticket所属voucher没有ticket了，则会核销该voucher。
  writeOffByVoucher 根据voucher的ID进行核销，该操作会将该voucher下的ticket都核销掉，再核销当前voucher
  该合约中，所有企业（包括核心企业、银行）都需要注册在Company中，核心企业和银行与普通企业的不同在于他们有没有在isCoreCompany isBank中，这两个map是public的，外部函数可查
没有getFinance，将凭证给银行的过程其实就是一个转发过程
银行对核心企业赋权、核销这部分可以有更多业务设置的空间，但是没有想好。
