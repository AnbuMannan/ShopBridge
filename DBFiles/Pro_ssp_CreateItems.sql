GO
IF NOT EXISTS(SELECT * FROM Sys.Objects WHERE Name ='ssp_CreateItems' AND Type='P') 
BEGIN       
EXEC ('CREATE PROCEDURE ssp_CreateItems AS BEGIN  SELECT 1  END ')
END
GO
ALTER PROC ssp_CreateItems
@ParamXML XML 
AS 
BEGIN
	 
	 DECLARE @RowCount INT
	 DECLARE @TotCount INT
	 DECLARE @StatusMessage VARCHAR(50)

	 IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp;
     CREATE TABLE #Temp (ItemCode VARCHAR(50) COLLATE DATABASE_DEFAULT, ItemName VARCHAR(100) COLLATE DATABASE_DEFAULT,
						 Description VARCHAR(100) COLLATE DATABASE_DEFAULT,SalePrice VARCHAR(50) COLLATE DATABASE_DEFAULT,
						 MRP VARCHAR(50) COLLATE DATABASE_DEFAULT, Stock VARCHAR(50) COLLATE DATABASE_DEFAULT)

	 INSERT INTO #Temp(ItemCode, ItemName, Description, SalePrice ,MRP , Stock )
	 SELECT	Data.value('(ItemCode/text())[1]','VARCHAR(50)') AS ItemCode,
			Data.value('(ItemName/text())[1]','VARCHAR(100)') AS ItemName,
			Data.value('(Description/text())[1]','VARCHAR(100)') AS [Description],
			Data.value('(SalePrice/text())[1]','VARCHAR(50)') AS SalePrice,
			Data.value('(MRP/text())[1]','VARCHAR(50)') AS MRP,
			Data.value('(Stock/text())[1]','VARCHAR(50)') AS Stock
	 FROM     
			@ParamXML.nodes('/Request/Items')AS DocData (Data)
	
	SET @RowCount= @@ROWCOUNT
	IF @RowCount =0
	BEGIN
		 RAISERROR('No Record to insert',16,1); RETURN;	
	END

	IF EXISTS(SELECT * FROM #Temp WHERE ISNULL(ItemCode,'')='') BEGIN RAISERROR('ItemCode is mandatory',16,1); RETURN; END
	IF EXISTS(SELECT * FROM #Temp WHERE ISNULL(ItemName,'')='') BEGIN RAISERROR('ItemName is mandatory',16,1); RETURN; END
	IF EXISTS(SELECT * FROM #Temp WHERE ISNULL(Description,'')='') BEGIN RAISERROR('Description is mandatory',16,1); RETURN; END
	IF EXISTS(SELECT * FROM #Temp WHERE (ISNULL(SalePrice,'')='' OR ISNULL(SalePrice,'')='0')) BEGIN RAISERROR('SalePrice is mandatory',16,1); RETURN; END
	IF EXISTS(SELECT * FROM #Temp WHERE (ISNULL(MRP,'')=''OR ISNULL(MRP,'')='0')) BEGIN RAISERROR('MRP is mandatory',16,1); RETURN; END
	IF EXISTS(SELECT * FROM #Temp WHERE (ISNULL(Stock,'')=''OR ISNULL(Stock,'')='0')) BEGIN RAISERROR('Stock is mandatory',16,1); RETURN; END

	IF EXISTS(SELECT * FROM #Temp WHERE ISNUMERIC(ISNULL(SalePrice,0))=0) BEGIN RAISERROR('SalePrice should be numeric',16,1); RETURN; END
	IF EXISTS(SELECT * FROM #Temp WHERE ISNUMERIC(ISNULL(MRP,0))=0) BEGIN RAISERROR('MRP should be numeric',16,1); RETURN; END
	IF EXISTS(SELECT * FROM #Temp WHERE ISNUMERIC(ISNULL(Stock,0))=0) BEGIN RAISERROR('Stock should be numeric',16,1); RETURN; END

	SET @TotCount = (SELECT COUNT(1) FROM #Temp)

	INSERT INTO tbl_ItemMaster (ItemCode,ItemName,Description,SalePrice,MRP,Stock,CreatedBy,CreatedDate,IsActive )
	SELECT  T.ItemCode,T.ItemName,T.Description,T.SalePrice,T.MRP,T.Stock,'Admin',CURRENT_TIMESTAMP,1
	FROM 
		#Temp T LEFT JOIN
		tbl_ItemMaster IM (NOLOCK) ON T.ItemCode = IM.ItemCode 
	WHERE IM.ID IS NULL

	SET @RowCount = @@ROWCOUNT
	
	IF @RowCount = @TotCount 
	BEGIN
		SET @StatusMessage = 'Items Created Successfully'
	END
	ELSE IF @RowCount = 0
	BEGIN
		SET @StatusMessage = 'All Items Already Available'
	END
	ELSE IF @RowCount < @TotCount
	BEGIN
		SET @StatusMessage = 'Partially Created and Few Items Already Available'
	END

	SELECT @StatusMessage AS Result

END