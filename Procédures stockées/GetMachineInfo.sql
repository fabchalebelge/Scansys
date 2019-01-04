CREATE PROCEDURE GetMachineInfo  
   @machineSerial CHAR(6)  
AS  
BEGIN
	SET NOCOUNT ON;
	SELECT
		[id],
		[assy_line]
	FROM 
		[Machines]
	WHERE
		[serial] = @machineSerial  
END
;