# SuppleChain
supple chain on unpay tickets, the blockchain summer school project.


SuppleChain2.0˵���ĵ�

�����ԭ�������ܺ�Լ�����پ���������һ��ֻ�ܴ���һ��ƾ֤������ͬʱ���ڶ�Һ�����ҵ��ͬʱǩ�����ƾ֤��������voucher��ticket���������ݽṹ������voucherΪ������ҵǩ����һ��ƾ֤��������Ϣ��һ��voucher���Զ�Ӧ����ticket��voucher������ǩ���ĺ�����ҵ���У����Բ鿴voucher�µ�����ticket��ticket������ƾ֤���������У������Խ���ת����ת���������ڷֲ���������µ�ticket�������µ�ticket�����ԭ����voucher���¡���ˣ�����ticket�����Ը���������voucher�鵽��������voucher�����Ա���ǩ���Ĺ�˾���飬��˸�ǩ����˾���Բ鿴�����Լ�ǩ����voucher��������ticket��������ת��

������¼�event

isCoreCompany ���Բ鿴���빫˾����ַ���Ƿ��Ǻ�����ҵ
isBank ���Բ鿴�Ƿ�������
addCompany��name��info�� Ϊ�Լ�ע�ᵱǰ��˾������info��ϢΪ��������������ӡ�������Ҫע�⣬����Ҫ��˾��Ψһ�����ṩ���ݹ�˾�����Ҷ�Ӧ��˾
addCoreCompany �����빫˾����ַ����Ϊ������ҵ��Ҫ������Ϊ��Լ�����߻������У�Ҫ�����빫˾�Ѿ�ע��
addBank �����빫˾��Ϊ���У�Ҫ������Ϊ��Լ�����߻������У�Ҫ�����빫˾�Ѿ�ע��
getCompany ��ȡ��˾��Ϣ
getVoucherById ��ȡvoucher��Ϣ
  ���ڽ�ƾ֤�ֳ�voucher��ticket��������������ticket�Ĺ�����Ϣ����洢��voucher�У�����˭ע��ģ�����voucher���ܶ����interest��ǩ������ signDate���������� dueDate����������destroyDate�����ʣ��������ڣ��������ڶ��Ǹ��ݴ����Ҫ����ģ�������ʵ�����󣬸�ģ�ͺ��滹���Լ�����չ�����������޶�������ҵ��ǩ������Ҫ����dueDate֮����ܺ����������destroyDate�����ú�����ҵ�Զ������ȡ�
getTicketsByVoucherͨ��voucher��ID��ȡ��voucher�������ִ��ticket
getTicketHistory ��õ�ǰticket����ת��ʷ
getMyTickets getMyVouchers ��÷��������µ�ticket��voucher
signAndTransfer ǩ��һ����λ
divideAndTransfer �����ʵ����transfer������ת��
writeOffByTicket ����ticket��ID���к���������ticket����voucherû��ticket�ˣ���������voucher��
writeOffByVoucher ����voucher��ID���к������ò����Ὣ��voucher�µ�ticket�����������ٺ�����ǰvoucher

�ú�Լ�У�������ҵ������������ҵ�����У�����Ҫע����Company�У�������ҵ����������ͨ��ҵ�Ĳ�ͬ����������û����isCoreCompany isBank�У�������map��public�ģ��ⲿ�����ɲ�
û��getFinance����ƾ֤�����еĹ�����ʵ����һ��ת������
���жԺ�����ҵ��Ȩ�������ⲿ�ֿ����и���ҵ�����õĿռ䣬����û����á�
