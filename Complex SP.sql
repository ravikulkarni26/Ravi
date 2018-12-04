use ibank
go

alter proc usp_UpdateBalance
(
 @ACID		char	
,@BRID		int(3)
,@TXNTYPE	char(3)
,@CHQNO		int
,@CHQDATE	smalldatetime
,@TXNAMT	smallmoney
,@UID		int	
)
as
begin

begin tran
   
	declare @dot datetime
	set @dot = getdate()

	declare @cbal money
	

	--Action1: Insert into TM Tables
	insert into TMASTER values (@dot,@ACID,@BRID, @TXNTYPE,@CHQNO,@CHQDATE,@TXNAMT,@UID)

	--error
	--Action2: Update AM
	--TxnType = 'CD'
	IF (@TXNTYPE = 'CD')
		begin 
			update AMASTER
			set cbal = cbal + @TXNAMT, ubal = ubal + @TXNAMT
			where acid = @acid
			
			commit
		end
	
	IF (@TXNTYPE = 'CW')
		begin 

			
		   --Check the customer's balance
		   --error
		   select @cbal = cbal from AMASTER where acid = @acid 

		    IF (@TXNAMT<=@cbal)
				begin 

					update AMASTER
					set cbal = cbal - @TXNAMT, ubal = ubal - @TXNAMT
					where acid = @acid

					commit
				
				end
			else
				begin
						print 'No funds in your account. Please call our customer care.'
						rollback
						
				end
		end

	IF (@TXNTYPE = 'CQD')
		begin 
			update AMASTER
			set  ubal = ubal + @TXNAMT
			where acid = @acid 

			commit
			
		end


end
go

/**********************
--call the sp
use ibank
go

select * from AMASTER where acid = 192

update AMASTER
set cbal = 4000, UBAL = 4000
where acid = 190

select * from AMASTER where acid = 190
select *   from TMASTER where acid = 190

insert into TMASTER values (getdate(), 192, 'BR1', 'CD', null,null,1000,2)
insert into TMASTER values (getdate(), 192, 'BR1', 'CD', null,null,5000,3)

insert into TMASTER values (getdate(), 190, 'BR4', 'CD', null,null,4500,5)
insert into TMASTER values (getdate(), 190, 'BR7', 'CD', null,null,4000,3)

sp_help TMASTER


--call SP
exec usp_UpdateBalance 192,'BR4','CQD', null,null,5000,1

exec usp_UpdateBalance 190,'BR1','CD', null,null,7000,1

exec usp_UpdateBalance 190,'BR1','CW', null,null,3000,1

exec usp_UpdateBalance 190,'BR1','CD', null,null,5000,1

exec usp_UpdateBalance 190,'BR1','CW', null,null,2000,1

exec usp_UpdateBalance 190,'BR1','CW', null,null,8700,1

select * from AMASTER where acid = 190
select *   from TMASTER where acid = 190

delete from TMASTER where Tno = 790

*********************************************/