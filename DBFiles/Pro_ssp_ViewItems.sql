GO
IF NOT EXISTS(SELECT * FROM Sys.Objects WHERE Name ='ssp_ViewItems' AND Type='P') 
BEGIN       
EXEC ('CREATE PROCEDURE ssp_ViewItems AS BEGIN  SELECT 1  END ')
END
GO
ALTER PROC ssp_ViewItems
@ParamXML XML = NULL
AS 
BEGIN
	 
	 DECLARE @RowCount INT
	 DECLARE @TotCount INT
	 DECLARE @StatusMessage VARCHAR(50)
	 DECLARE @XMLDATA AS XML


	SET @XMLDATA = (SELECT
		ID AS SystemUniqueID,
		ItemCode,
		ItemName,
		[Description],
		CAST(ISNULL(SalePrice,'')  AS numeric(15,3)) AS SalePrice,
		CAST(ISNULL(MRP,'')  AS numeric(15,3)) AS MRP,
		CAST(ISNULL(Stock,'')  AS numeric(15,3)) AS Stock,
		CASE IsActive WHEN 1 THEN 'TRUE' WHEN 0 THEN 'FALSE' END AS IsActive
	 FROM
		 tbl_ItemMaster (NOLOCK)
	 FOR XML PATH('Item'), ROOT('InventoryItems'), TYPE)

	IF @XMLDATA IS NULL
	BEGIN
		 RAISERROR('No Items',16,1); RETURN;	
	END

	 SELECT @XMLDATA AS Result
END