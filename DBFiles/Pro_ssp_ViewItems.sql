GO
IF NOT EXISTS(SELECT * FROM Sys.Objects WHERE Name ='ssp_ViewItems' AND Type='P') 
BEGIN       
EXEC ('CREATE PROCEDURE ssp_ViewItems AS BEGIN  SELECT 1  END ')
END
GO
ALTER PROC [dbo].[ssp_ViewItems]
@ParamXML XML = NULL
AS 
BEGIN
	 
	 DECLARE @RowCount INT
	 DECLARE @TotCount INT
	 DECLARE @StatusMessage VARCHAR(50)
	 DECLARE @XMLDATA AS XML
	 DECLARE @PageSize INT
	 DECLARE @PageNo INT
	 DECLARE @PageCount INT
	 DECLARE @NodeCount INT

	 SET @PageSize = 10
	 SET @PageNo = 1

	 SET @PageCount = (SELECT COUNT(1) FROM tbl_ItemMaster (NOLOCK))
	 SET @NodeCount = (SELECT COUNT(1) FROM tbl_ItemMaster (NOLOCK))

		IF((@PageCount%@PageSize) >0)
			SET @PageCount = (@PageCount/@PageSize) + 1 
		ELSE
			SET @PageCount = (@PageCount/@PageSize) 

		IF @PageNo < 0 OR @PageNo = 0
		BEGIN
			SET @PageNo = 1
		END
		ELSE IF @PageNo > @PageCount
		BEGIN
			SET @PageNo = @PageCount
		END
		ELSE IF @PageNo IS NULL
		BEGIN
			SET @PageNo = 1
		END

		IF @PageNo = 0
		BEGIN
			SET @PageNo = 1
		END

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
		ORDER BY ID
		OFFSET ((@PageNo - 1)  * @PageSize) ROWS
		FETCH NEXT @PageSize ROWS ONLY		
	 FOR XML PATH('Item'), ROOT('InventoryItems'), TYPE)

	IF @XMLDATA IS NULL
	BEGIN
		 RAISERROR('No Items',16,1); RETURN;	
	END

	DECLARE @PageSummaryNode XML
				SET @PageSummaryNode = '<PageSummary><PageCount>'+ CONVERT(VARCHAR(10),ISNULL(@PageCount,0)) +'</PageCount>
													 <PageNo>'+ CONVERT(VARCHAR(10),@PageNo) + '</PageNo>
													 <NodeCount>'+ CONVERT(VARCHAR(10),ISNULL(@NodeCount,0)) + '</NodeCount>
										</PageSummary>'
				SET @XMLData.modify('insert sql:variable("@PageSummaryNode") as first into  (/InventoryItems)[1]')

	 SELECT @XMLDATA AS Result
END
