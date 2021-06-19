GO
IF NOT EXISTS(SELECT * FROM Sys.Objects WHERE Name ='ssp_UpdateItems' AND Type='P') 
BEGIN       
EXEC ('CREATE PROCEDURE ssp_UpdateItems AS BEGIN  SELECT 1  END ')
END
GO
ALTER PROC ssp_UpdateItems
@ParamXML XML 
AS 
BEGIN
	 
	 DECLARE @RowCount INT
	 DECLARE @TotCount INT
	 DECLARE @StatusMessage VARCHAR(50)

	 IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp;
     CREATE TABLE #Temp (ItemCode VARCHAR(50) COLLATE DATABASE_DEFAULT, ItemName VARCHAR(100) COLLATE DATABASE_DEFAULT,
						 Description VARCHAR(100) COLLATE DATABASE_DEFAULT,SalePrice VARCHAR(10) COLLATE DATABASE_DEFAULT,
						 MRP VARCHAR(10) COLLATE DATABASE_DEFAULT, Stock VARCHAR(10) COLLATE DATABASE_DEFAULT, IsActive VARCHAR(10) COLLATE DATABASE_DEFAULT)

	 INSERT INTO #Temp(ItemCode, ItemName, Description, SalePrice ,MRP , Stock,IsActive)
	 SELECT	Data.value('(ItemCode/text())[1]','VARCHAR(50)') AS ItemCode,
			Data.value('(ItemName/text())[1]','VARCHAR(100)') AS ItemName,
			Data.value('(Description/text())[1]','VARCHAR(100)') AS [Description],
			Data.value('(SalePrice/text())[1]','VARCHAR(10)') AS SalePrice,
			Data.value('(MRP/text())[1]','VARCHAR(10)') AS MRP,
			Data.value('(Stock/text())[1]','VARCHAR(10)') AS Stock,
			Data.value('(IsActive/text())[1]','VARCHAR(10)') AS IsActive
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
	IF EXISTS(SELECT * FROM #Temp WHERE ISNULL(IsActive ,'') NOT IN ('TRUE','FALSE')) BEGIN RAISERROR('Invalid value in IsActive',16,1); RETURN; END

	SET @TotCount = (SELECT COUNT(1) FROM #Temp)

	UPDATE IM SET 
		IM.ItemCode = T.ItemCode,IM.ItemName = T.ItemName,
		IM.Description = T.Description,IM.SalePrice = T.SalePrice,
		IM.MRP = T.MRP,IM.Stock = T.Stock,
		IM.ModifiedBy = 'Admin', IM.ModifiedDate = CURRENT_TIMESTAMP,
		IM.IsActive = CASE T.IsActive WHEN 'TRUE' THEN 1 WHEN 'FALSE' THEN 0 END 
	FROM 
		#Temp T INNER JOIN
		tbl_ItemMaster IM (NOLOCK) ON T.ItemCode = IM.ItemCode 

	SET @RowCount = @@ROWCOUNT
	
	IF @RowCount = @TotCount 
	BEGIN
		SET @StatusMessage = 'Items Updated Successfully'
	END
	ELSE IF @RowCount = 0
	BEGIN
		RAISERROR('Items Not Available',16,1); RETURN;	
	END
	ELSE IF @RowCount < @TotCount
	BEGIN
		SET @StatusMessage = 'Partially Updated and Few Items Not Available'
	END

	SELECT @StatusMessage AS Result

END