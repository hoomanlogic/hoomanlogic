
-- blocks: need to be able to log an action on the fly, which tries to find an existing one, instead of adding a future todo/action
--         need recurring actions/todos to show in the next actions list
use [hoomanlogic]
go

create table [dbo].[Preferences] (
	[UserId] nvarchar(128) not null constraint [PK_Preferences] primary key,
	[WeekStarts] tinyint not null constraint [DF_Preferences_WeekStarts] default (0),
	[Location] varchar(100) null,
	[EmailNotifications] bit not null constraint [DF_Preferences_EmailNotifications] default (0),
    constraint [FK_Preferences_User] foreign key (UserId) 
    references [dbo].[AspNetUsers] (Id) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[Focuses] (
	[Id] uniqueidentifier not null constraint [PK_Focuses] primary key,
	[UserId] nvarchar(128) not null,
	[Name] varchar(255) not null,
	[Kind] varchar(20) not null,
	[TagName] varchar(20) not null,
	[Enlist] datetime null,
	[Retire] datetime null,
	[IconUri] varchar(256) null,
	constraint [AK_Focuses] unique ([UserId], [Name]),
    constraint [FK_Focuses_User] foreign key (UserId) 
    references [dbo].[AspNetUsers] (Id) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[Projects] (
	[Id] uniqueidentifier not null constraint [PK_Projects] primary key,
	[FocusId] uniqueidentifier not null,
	[UserId] nvarchar(128) not null,
	[Name] varchar(255) not null,
	[Kind] varchar(20) not null,
	[TagName] varchar(20) not null,
	[Enlist] datetime null,
	[Retire] datetime null,
	[Content] varchar(max) null,
	[IconUri] varchar(256) null,
	constraint [AK_Projects] unique ([UserId], [Name]),
    constraint [FK_Projects_Users] foreign key (UserId) 
    references [dbo].[AspNetUsers] (Id) 
    on delete cascade
    on update cascade,
    constraint [FK_Projects_Focuses] foreign key (FocusId) 
    references [dbo].[Focuses] (Id) 
    on delete no action
    on update no action
)
go

create table [dbo].[ProjectSteps] (
	[Id] uniqueidentifier not null constraint [PK_ProjectSteps] primary key,
	[ProjectId] uniqueidentifier not null,
	[ParentId] uniqueidentifier null,
	[UserId] nvarchar(128) not null,
	[Name] varchar(255) not null,
	[Kind] varchar(20) not null,
	[Created] datetime null,
	[Duration] smallint null,
	[Status] varchar(20) not null constraint [DF_ProjectSteps_Status] default ('Todo'), --Todo,Doing,Ready,Done
	[TagName] varchar(20) null,
	[Ordinal] smallint null,
	[Content] varchar(max) null,
	--constraint [AK_ProjectSteps] unique ([ProjectId], [Name]),
 --   constraint [FK_ProjectSteps_Projects] foreign key (ProjectId) 
 --   references [dbo].[Projects] (Id) 
 --   on delete cascade
 --   on update cascade
    --constraint [FK_ProjectSteps_Users] foreign key (UserId) 
    --references [dbo].[AspNetUsers] (Id) 
    --on delete no action
    --on update no action,
    --constraint [FK_ProjectSteps_Parent] foreign key (ParentId) 
    --references [dbo].[ProjectSteps] (Id) 
    --on delete no action
    --on update no action
)
go

create table [dbo].[Actions] (
	[Id] uniqueidentifier not null constraint [PK_Actions] primary key,
	[UserId] nvarchar(128) not null,
	[Name] varchar(255) not null,
	[Kind] varchar(20) not null,
	[Created] datetime null,
	[Duration] smallint null,
	[NextDate] datetime null,
	[Content] varchar(max) null,
	[Ordinal] smallint null,
	[ProjectStepId] uniqueidentifier null,
	[IsPublic] bit not null constraint [DF_Actions_IsPublic] default (0),
	constraint [AK_Actions] unique ([UserId], [Name]),
    constraint [FK_Action_User] foreign key (UserId) 
    references [dbo].[AspNetUsers] (Id) 
    on delete cascade
    on update cascade
    --constraint [FK_Actions_ProjectSteps] foreign key (ProjectStepId) 
    --references [dbo].[ProjectSteps] (Id) 
    --on delete no action
    --on update no action
)
go

create table [dbo].[ArchivedActions] (
	[Id] uniqueidentifier not null,
	[UserId] nvarchar(128) not null,
	[Name] varchar(255) not null,
	[Kind] varchar(20) not null,
	[Created] datetime null,
	[Duration] smallint null,
	[NextDate] datetime null,
	[Content] varchar(max) null,
	[Ordinal] smallint null,
	[ProjectStepId] uniqueidentifier null,
	[IsPublic] bit not null
)
go

create table [dbo].[Attachments] (
	[Id] uniqueidentifier not null constraint [PK_Attachments] primary key,
	[UserId] nvarchar(128) not null,
	[Name] varchar(100) not null,
	[Kind] varchar(10) not null constraint [DF_Attachments_Kind] default ('File'),
	[Path] varchar(256) not null, 
	constraint [AK_Attachments] unique ([UserId], [Path]),
	constraint [FK_Attachments_Users] foreign key (UserId) 
    references [dbo].[AspNetUsers] (Id) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[ActionsAttachments] (
	[ActionId] uniqueidentifier not null,
	[AttachmentId] uniqueidentifier not null,
	constraint [PK_ActionsAttachments] primary key ([ActionId], [AttachmentId]),
	constraint [FK_ActionsAttachments_Attachments] foreign key ([AttachmentId])
	references [dbo].[Attachments] ([Id])
	on delete no action
    on update no action,
	constraint [FK_ActionsAttachments_Actions] foreign key ([ActionId])
	references [dbo].[Actions] ([Id])
	on delete no action
    on update no action
)
go

--create table [dbo].[ActionPathways] (
--	[RootId] uniqueidentifier not null,
--	[ParentId] uniqueidentifier not null,
--	[ChildId] uniqueidentifier not null,
--	[Order] tinyint null,
--	constraint [PK_[ActionPathways] primary key ([RootId], [ParentId], [ChildId]),
--	constraint [FK_ActionPathways_Root] foreign key ([RootId]) 
--    references [dbo].[Actions] (Id) 
--    on delete no action
--    on update no action,
--	constraint [FK_ActionPathways_Parent] foreign key ([ParentId]) 
--    references [dbo].[Actions] (Id) 
--    on delete no action
--    on update no action,
--	constraint [FK_ActionPathways_Child] foreign key ([ChildId]) 
--    references [dbo].[Actions] (Id) 
--    on delete no action
--    on update no action
--)

create table [dbo].[RecurrenceRules] (
	[ActionId] uniqueidentifier not null,
	[Rule] varchar(500) not null,
	constraint [PK_RecurrenceRules] primary key ([ActionId], [Rule]),
	constraint [FK_RecurrenceRules_Actions] foreign key (ActionId) 
    references [dbo].[Actions] (Id) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[LogEntries] (
	[Id] uniqueidentifier not null constraint [PK_LogEntries] primary key,
	[ActionId] uniqueidentifier not null,
	[RootActionId] uniqueidentifier null,
	[Date] datetime not null,
	[Entry] varchar(50) not null,
	[Duration] smallint null,
	[Details] varchar(MAX) null,
	constraint [FK_LogEntries_Actions] foreign key ([ActionId])
	references [dbo].[Actions] ([Id])
	on delete no action
    on update no action
)
go

create table [dbo].[ArchivedLogEntries] (
	[Id] uniqueidentifier not null,
	[ActionId] uniqueidentifier not null,
	[RootActionId] uniqueidentifier null,
	[Date] datetime not null,
	[Entry] varchar(50) not null,
	[Duration] smallint null,
	[Details] varchar(MAX) null
)
go

create table [dbo].[LogEntryPeanuts] (
	[Id] uniqueidentifier not null constraint [PK_LogEntryPeanuts] primary key,
	[UserId] nvarchar(128) not null,
	[LogEntryId] uniqueidentifier not null,
	[Date] datetime not null,
	[Kind] varchar(10) not null constraint [DF_LogEntryPeanuts_Kind] default ('Support'),
	[Comment] varchar(1000) null,
	[AttachmentUri] varchar(256) null,
	constraint [FK_LogEntryPeanuts_LogEntries] foreign key (LogEntryId) 
    references [dbo].[LogEntries] (Id) 
    on delete cascade
    on update cascade,
	constraint [FK_LogEntryPeanuts_Users] foreign key (UserId) 
    references [dbo].[AspNetUsers] (Id) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[ArchivedLogEntryPeanuts] (
	[Id] uniqueidentifier not null,
	[UserId] nvarchar(128) not null,
	[LogEntryId] uniqueidentifier not null,
	[Date] datetime not null,
	[Kind] varchar(10) not null,
	[Comment] varchar(1000) null,
	[AttachmentUri] varchar(256) null
)
go
 
create table [dbo].[Tags] (
	[Id] uniqueidentifier not null constraint [PK_Tags] primary key,
	[UserId] nvarchar(128) not null,
	[Name] varchar(20) not null constraint [CK_Tags_Name] check (CHARINDEX(' ', [Name]) = 0),
	[Kind] varchar(10) not null constraint [DF_Tags_Kind] default ('Tag'),
	[Path] varchar(200) not null, -- must begin and end with backslash so we can test if a tag is a descendant without error in Target testing (ie. /learn/language/german
	[Content] varchar(max) null,
	constraint [AK_Tags] unique ([UserId], [Name]),
	constraint [FK_Tags_Users] foreign key (UserId) 
    references [dbo].[AspNetUsers] (Id) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[Targets] (
	[Id] uniqueidentifier not null constraint [PK_Targets] primary key,
	[UserId] nvarchar(128) not null,
	[TagId] uniqueidentifier not null,
	[Kind] varchar(10) not null,
	[Timeline] varchar(500) not null,
	[Goal] smallint not null,
	[Enlist] datetime null,
	[Retire] datetime null,
	constraint [FK_Targets_Tags] foreign key ([TagId])
	references [dbo].[Tags] ([Id])
	on delete no action
    on update no action,
	constraint [FK_Targets_Users] foreign key (UserId) 
    references [dbo].[AspNetUsers] (Id) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[ActionsTags] (
	[ActionId] uniqueidentifier not null,
	[TagId] uniqueidentifier not null,
	constraint [PK_ActionsTags] primary key ([ActionId], [TagId]),
	constraint [FK_ActionsTags_Tags] foreign key ([TagId])
	references [dbo].[Tags] ([Id])
	on delete no action
    on update no action,
	constraint [FK_ActionsTags_Actions] foreign key ([ActionId])
	references [dbo].[Actions] ([Id])
	on delete no action
    on update no action
)
go

create table [dbo].[ArchivedActionsTags] (
	[ActionId] uniqueidentifier not null,
	[TagId] uniqueidentifier not null
)
go

create table [dbo].[Personas] (
	[UserId] nvarchar(128) not null,
	[Kind] varchar(50) not null,
	[KnownAs] varchar(50) null,
	[ProfileUri] varchar(256) null,
	constraint [PK_Personas] primary key ([UserId], [Kind]),
	constraint [FK_Personas_Users] foreign key ([UserId]) 
    references [dbo].[AspNetUsers] ([Id]) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[Connections] (
	[UserId] nvarchar(128) not null,
	[Persona] varchar(50) not null,
	[UserId_Connection] nvarchar(128) not null,
	[Persona_Connection] varchar(50) not null,
	constraint [PK_Connections] primary key ([UserId], [UserId_Connection]),
	constraint [FK_Connections_Users_User1] foreign key ([UserId]) 
    references [dbo].[AspNetUsers] ([Id]) 
    on delete cascade
    on update cascade,
	constraint [FK_Connections_Users_User2] foreign key ([UserId_Connection]) 
    references [dbo].[AspNetUsers] ([Id]) 
    on delete no action
    on update no action,
	constraint [FK_Connections_Personas1] foreign key ([UserId], [Persona]) 
    references [dbo].[Personas] ([UserId], [Kind]) 
    on delete no action
    on update no action,
	constraint [FK_Connections_Personas2] foreign key ([UserId_Connection], [Persona_Connection]) 
    references [dbo].[Personas] ([UserId], [Kind]) 
    on delete no action
    on update no action
)
go

create table [dbo].[ConnectionRequests] (
	[UserId] nvarchar(128) not null,
	[UserId_RequestedBy] nvarchar(128) not null,
	[Persona] varchar(50) not null,
	constraint [PK_ConnectionRequests] primary key ([UserId], [UserId_RequestedBy])
)
go

create table [dbo].[Messages] (
	[Id] uniqueidentifier not null constraint [PK_Messages] primary key,
	[UserId_From] nvarchar(128) not null,
	[UserId_To] nvarchar(128) not null,
	[Text] nvarchar(max) null,
	[Uri] varchar(255) null,
	[Sent] datetime not null constraint [DF_Messages_Sent] default (getutcdate()),
	[Read] datetime null,
	constraint [FK_Messages_Users_From] foreign key ([UserId_From]) 
    references [dbo].[AspNetUsers] ([Id]) 
    on delete cascade
    on update cascade,
	constraint [FK_Messages_Users_To] foreign key ([UserId_To]) 
    references [dbo].[AspNetUsers] ([Id]) 
    on delete no action
    on update no action
)
go

create table [dbo].[Achievements] (
	[Id] uniqueidentifier not null constraint [PK_Achievements] primary key,
	[UserId] nvarchar(128) not null,
	[Date] datetime null,
	[Content] nvarchar(max) null,
	[IsPublic] bit not null constraint [DF_Achievements_IsPublic] default (0),
	constraint [FK_Achievements_Users] foreign key ([UserId]) 
    references [dbo].[AspNetUsers] ([Id]) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[Notifications] (
	[Id] uniqueidentifier not null constraint [PK_Notifications] primary key,
	[UserId] nvarchar(128) not null,
	[OccurredAt] datetime not null,
	[Kind] varchar(128) not null,
	[Subject] varchar(128) not null,
	[Context] nvarchar(max) null,
	[ReadAt] datetime null,
	constraint [FK_Notifications_Users] foreign key ([UserId]) 
    references [dbo].[AspNetUsers] ([Id]) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[Services] (
	[Id] uniqueidentifier not null constraint [PK_Services] primary key,
	[UserId] nvarchar(128) not null,
	[Persona] varchar(50) not null,
	[Kind] varchar(50) not null,
	constraint [AK_Services] unique ([UserId], [Persona], [Kind]),
)
go

create table [dbo].[Resources] (
	[Id] uniqueidentifier not null constraint [PK_Resources] primary key,
	[UserId] nvarchar(128) not null,
	[Persona] varchar(50) not null,
	[Kind] varchar(50) not null,
	constraint [AK_Resources] unique ([UserId], [PersonaId], [Kind]),
	[MayLend] bit not null constraint [DF_Resources_MayLend] default (0),
	[ForSale] bit not null constraint [DF_Resources_MayLend] default (0),
)
go