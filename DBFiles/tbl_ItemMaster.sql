CREATE TABLE [dbo].[tbl_ItemMaster](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ItemCode] [varchar](50) NOT NULL,
	[ItemName] [varchar](100) NULL,
	[Description] [varchar](100) NULL,
	[SalePrice] [float] NULL,
	[MRP] [float] NULL,
	[Stock] [float] NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [varchar](50) NULL,
 CONSTRAINT [PK_tbl_ItemMaster] PRIMARY KEY CLUSTERED 
(
	[ItemCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


