GO
IF NOT EXISTS(SELECT * FROM Sys.Objects WHERE Name ='ssp_DeleteItems' AND Type='P') 
BEGIN       
EXEC ('CREATE PROCEDURE ssp_DeleteItems AS BEGIN  SELECT 1  END ')
END
GO
ALTER PROC ssp_DeleteItems
@ParamXML XML 
AS 
BEGIN
	 
	 DECLARE @RowCount INT
	 DECLARE @TotCount INT
	 DECLARE @StatusMessage VARCHAR(50)

	 IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp;
     CREATE TABLE #Temp (ItemCode VARCHAR(50) COLLATE DATABASE_DEFAULT)

	 INSERT INTO #Temp(ItemCode )
	 SELECT	Data.value('(ItemCode/text())[1]','VARCHAR(50)') AS ItemCode
	 FROM     
			@ParamXML.nodes('/Request/Items')AS DocData (Data)
	
	SET @RowCount= @@ROWCOUNT
	IF @RowCount =0
	BEGIN
		 RAISERROR('No Record to insert',16,1); RETURN;	
	END

	IF EXISTS(SELECT * FROM #Temp WHERE ISNULL(ItemCode,'')='') BEGIN RAISERROR('ItemCode is mandatory',16,1); RETURN; END
	
	SET @TotCount = (SELECT COUNT(1) FROM #Temp)

	DELETE IM  
	FROM 
		#Temp T INNER JOIN
		tbl_ItemMaster IM (NOLOCK) ON T.ItemCode = IM.ItemCode 

	SET @RowCount = @@ROWCOUNT
	
	IF @RowCount = @TotCount 
	BEGIN
		SET @StatusMessage = 'Items Deleted Successfully'
	END
	ELSE IF @RowCount = 0
	BEGIN
		RAISERROR('Items Not Available',16,1); RETURN;	
	END
	ELSE IF @RowCount < @TotCount
	BEGIN
		SET @StatusMessage = 'Partially Deleted and Few Items Not Available'
	END

	SELECT @StatusMessage AS Result

END