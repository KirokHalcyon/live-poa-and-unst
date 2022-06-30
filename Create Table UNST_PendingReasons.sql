USE [SharedServices]
GO

CREATE TABLE [dbo].[UNST_PendingReasons]
(
    [ReasonID] [int] IDENTITY(1,1) NOT NULL,
    [ReasonDesc] [varchar](255) NOT NULL,
    CONSTRAINT [PK_UNST_PendingReasons] PRIMARY KEY CLUSTERED 
(
	[ReasonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO [dbo].[UNST_PendingReasons]
    ([ReasonDesc])
VALUES
    ('PA was previously cleared'),
    ('Invoice previously cleared'),
    ('PA not on account'),
    ('CM not on account'),
    ('CM previously cleared'),
    ('Unprocessed invoice')
GO