
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

insert into Preferences (UserId) select Id from AspNetUsers

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

update Actions set Retire = null Where id = '1218B0AA-2EEA-4380-9ABD-A4727D9B1780'
update Actions set Kind = 'Action' where id = '1218B0AA-2EEA-4380-9ABD-A4727D9B1780'
select * from LogEntries where actionid in ('EBA2B5E5-DD21-43B2-8C5B-F09CDA98C3AC','1218B0AA-2EEA-4380-9ABD-A4727D9B1780')
-- add NextActionId to Focuses, or maybe this should be calculated based on targets
select * from RecurrenceRules
select * from Actions order by enlist desc
insert into Focuses values (
'FA62A5A6-AD2B-41A3-9D56-036BC02E8ADD',
'db6f45f8-0c0e-4135-9a29-0be2c79a4eb1',
'Software Architect',
'Role',
'develop',
'2015-01-11 00:00:00.000', NULL, '/uploads/db6f45f8-0c0e-4135-9a29-0be2c79a4eb1/focus/brackets.png')
insert into Focuses values (
NEWID(),
'db6f45f8-0c0e-4135-9a29-0be2c79a4eb1',
'Employee',
'Role',
'work',
'2015-01-11 00:00:00.000', NULL, '/uploads/db6f45f8-0c0e-4135-9a29-0be2c79a4eb1/focus/chslogo.png')
insert into Focuses values (
NEWID(),
'db6f45f8-0c0e-4135-9a29-0be2c79a4eb1',
'Sable''s Steward',
'Role',
'sable',
'2015-01-11 00:00:00.000', NULL, '/uploads/db6f45f8-0c0e-4135-9a29-0be2c79a4eb1/focus/sable.png')
insert into Focuses values (
NEWID(),
'db6f45f8-0c0e-4135-9a29-0be2c79a4eb1',
'Musician',
'Role',
'music',
'2015-01-11 00:00:00.000', NULL, '/uploads/db6f45f8-0c0e-4135-9a29-0be2c79a4eb1/focus/guitar.png')
insert into Focuses values (
NEWID(),
'db6f45f8-0c0e-4135-9a29-0be2c79a4eb1',
'Growth',
'Path',
'grow',
'2015-01-11 00:00:00.000', NULL, '/uploads/db6f45f8-0c0e-4135-9a29-0be2c79a4eb1/focus/growth.png')
insert into Focuses values (
NEWID(),
'db6f45f8-0c0e-4135-9a29-0be2c79a4eb1',
'Hooman',
'Role',
'hooman',
'2015-01-11 00:00:00.000', NULL, '/uploads/db6f45f8-0c0e-4135-9a29-0be2c79a4eb1/focus/hooman.png')
select * from Focuses
-- Joy
insert into Focuses values (
NEWID(),
'aee5e6a4-120a-4173-92b0-6782a85fedef',
'Hooman',
'Role',
'hooman',
'2015-02-03 00:00:00.000', NULL, '/uploads/aee5e6a4-120a-4173-92b0-6782a85fedef/focus/hooman.png')

-- FOR ADDING THE FIRST FOCUS AND SETTING HOOMAN TAG TO A FOCUS
--insert into Focuses values (
--NEWID(),
--'cc3c9992-c766-48af-9068-a8d6b52cdff2',
--'Hooman',
--'Role',
--'2015-02-03 00:00:00.000', NULL, '/uploads/cc3c9992-c766-48af-9068-a8d6b52cdff2/focus/hooman.png','hooman')
--select * from Actions where userid = 'cc3c9992-c766-48af-9068-a8d6b52cdff2'
--select * from Tags where userid = 'cc3c9992-c766-48af-9068-a8d6b52cdff2'
--update Tags set IsFocus = 1, Kind = 'Focus' where userid = 'cc3c9992-c766-48af-9068-a8d6b52cdff2'

select * from ActionsTags where actionid = 'E229AD6F-9B95-40AB-BFA3-CFE039123B97'
'A626D4BA-9296-4384-BB07-5726FFDA0DD7'
create table [dbo].[Actions] (
	[Id] uniqueidentifier not null constraint [PK_Actions] primary key,
	[UserId] nvarchar(128) not null,
	[Name] varchar(255) not null,
	[Kind] varchar(20) not null,
	[Enlist] datetime null,
	[Retire] datetime null,
	[StartAt] smallint null,
	[Duration] smallint null,
	[NextDate] datetime null,
	[IsSomeday] bit not null constraint [DF_Actions_IsSomeday] default (0),
	[Content] varchar(max) null,
	constraint [AK_Actions] unique ([UserId], [Name]),
    constraint [FK_Action_User] foreign key (UserId) 
    references [dbo].[AspNetUsers] (Id) 
    on delete cascade
    on update cascade
)
go

create table [dbo].[ActionPathways] (
	[RootId] uniqueidentifier not null,
	[ParentId] uniqueidentifier not null,
	[ChildId] uniqueidentifier not null,
	[Order] tinyint null,
	constraint [PK_[ActionPathways] primary key ([RootId], [ParentId], [ChildId]),
	constraint [FK_ActionPathways_Root] foreign key ([RootId]) 
    references [dbo].[Actions] (Id) 
    on delete no action
    on update no action,
	constraint [FK_ActionPathways_Parent] foreign key ([ParentId]) 
    references [dbo].[Actions] (Id) 
    on delete no action
    on update no action,
	constraint [FK_ActionPathways_Child] foreign key ([ChildId]) 
    references [dbo].[Actions] (Id) 
    on delete no action
    on update no action
)

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
	[Details] varchar(MAX) null
)
go
 
create table [dbo].[Tags] (
	[Id] uniqueidentifier not null constraint [PK_Tags] primary key,
	[UserId] nvarchar(128) not null,
	[Name] varchar(20) not null constraint [CK_Tags_Name] check (CHARINDEX(' ', [Name]) = 0),
	[Kind] varchar(10) not null constraint [DF_Tags_Kind] default ('Tag'),
	[Path] varchar(200) not null, -- must begin and end with backslash so we can test if a tag is a descendant without error in Target testing (ie. /learn/language/german
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

-- create a persona for a new user
--insert into Personas values ('cc3c9992-c766-48af-9068-a8d6b52cdff2', 'Public', 'Jason Boyd', '/uploads/cc3c9992-c766-48af-9068-a8d6b52cdff2/Public/profile.jpg')
--insert into [Connections] values ('cc3c9992-c766-48af-9068-a8d6b52cdff2', 'Public', 'db6f45f8-0c0e-4135-9a29-0be2c79a4eb1', 'Public')
--insert into [Connections] values ('db6f45f8-0c0e-4135-9a29-0be2c79a4eb1', 'Public', 'cc3c9992-c766-48af-9068-a8d6b52cdff2', 'Public')
--go

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