/**************************************************************************
 * Custom error messages
 ***************************************************************************/
 
-- Add error message for patient update optimistic lock exception
IF EXISTS (
	SELECT 1
	FROM sys.messages
	WHERE
	message_id = 50101
)
EXEC sp_dropmessage @msgnum = 50101, @lang = 'all';
GO

EXEC sp_addmessage 50101, 16, 'Optimistic lock occurred during update operation'
GO

-- Add error message for operator not found exception
IF EXISTS (
	SELECT 1
	FROM sys.messages
	WHERE
	message_id = 50102
)
EXEC sp_dropmessage @msgnum = 50102, @lang = 'all';
GO

EXEC sp_addmessage 50102, 16, 'Record not found'
GO

-- Add error message for operator already exists exception
IF EXISTS (
	SELECT 1
	FROM sys.messages
	WHERE
	message_id = 50104
)
EXEC sp_dropmessage @msgnum = 50104, @lang = 'all';
GO

EXEC sp_addmessage 50104, 16, 'Record already exists'
GO

if exists (select * from sysobjects where id = object_id(N'dbo.WebAPI_SBC_GetAppointments') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WebAPI_SBC_GetAppointments
go

/**************************************************************************
 * Proc Name:     WebAPI_SBC_GetAppointments
 * 
 * Purpose:       Return the list of appointments for SBC API.
 * 
 * Rules:         
 * 
 * Parameters:    CorpID		INT	- Corporation identifier.
 *                UserID		VARCHAR(100) - The user id who performs this operation.
 *				  MachineName	VARCHAR(200) - Machine name where SBC API is running.
 *                ExtLocID		VARCHAR(255) - Location ID in RT system, or NULL.
 *                StartDate		DATETIME - Appointments from date (inclusive).
 *                EndDate		DATETIME - Appointments to date (inclusive).
 * 
 * Returns:       Appointments filtered by external location ID and dates.
 * 
 * Called By:	  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/
GO

CREATE PROCEDURE dbo.WebAPI_SBC_GetAppointments
    @CorpID         INT,
    @UserID         VARCHAR(100),
    @MachineName	VARCHAR(200),
    @ExtLocID       VARCHAR(255),
    @StartDate      DATETIME,
    @EndDate        DATETIME
AS

DECLARE @RetCode INT

-- Validate the user.
EXEC @RetCode = ValidateUser @CorpID, @UserID
IF @RetCode <> 1 
BEGIN
    RAISERROR(51300,16,1)
    RETURN
END

--------------------------------------------------
--------------------------------------------------
-- INTERNAL WORKING VARS
DECLARE 
    @RTExtSysName   VARCHAR(30),
    @SBCExtSysName  VARCHAR(30),
    @SBCApptType	VARCHAR(255),
    @ExtAT95Attribute VARCHAR(512)
    
    

--------------------------------------------------
SELECT
    @RTExtSysName   = 'RMT',    -- Specific value
    @SBCExtSysName  = 'SBC',    -- Specific value
    @SBCApptType	= 'IE',
    @ExtAT95Attribute = 'AT95/ExtApptTypeId'

--------------------------------------------------
--------------------------------------------------
DECLARE @Appointments TABLE (
	[CorpID] INT,
    [CaseKey] INT,
    [ApptSequence] SMALLINT,
    [DateOfVisit] DATETIME,
	[ClinicKey] SMALLINT,
    [ApptTypeDescription] VARCHAR(40),
    [ApptStatusDescription] VARCHAR(30),
	[Comment] VARCHAR(2000),
    [ColorCode] INT,
    [ExternalLocationID] VARCHAR(255),
    [ExternalID] VARCHAR(255),
    [PatientKey] INT,
    [PT10NameF] VARCHAR(30),
    [PT10NameL] VARCHAR(30),
    [PT10NameI] CHAR(1),
    [TherpstKey] INT,
    [TherpstNameL] varchar(30),
	[TherpstNameF] varchar(30),
	[TherpstNameI] varchar(1),
	[TherpstExternalID] varchar(255)
	)

BEGIN TRY
	BEGIN TRANSACTION;
	
	INSERT INTO @Appointments
	SELECT
		[CorpID] = PT15.CorpID,
		[CaseKey] = PT15.CaseKey,
		[ApptSequence] = PT15.Apptseq,
		[DateOfVisit] = PT15.PT15ApptDat,
		[ClinicKey] = PT15.ClinicKey,
		[ApptTypeDescription] = AT95.AT95Text,
		[ApptStatusDescription] = ST15.ST15Text,
		[Comment] = PT15.PT15Comment,
		[ColorCode] = PT15.PT15ApptColor,
		[ExternalLocationID] = IFAT_AT11.ExtVal, -- Account / CaseID when RMT
		[ExternalID] = IFPT_PT11.ExtVal, -- LocationID when RMT
		[PatientKey] = PT10.PatientKey,
		[PT10NameF]	= PT10.PT10NameF,
		[PT10NameL] = PT10.PT10NameL,
		[PT10NameI] = PT10.PT10NameI,
		[TherpstKey] = PT15.TherpstKey,
	    [TherpstNameL] = AT20.AT20NameL,
		[TherpstNameF] = AT20.AT20NameF,
		[TherpstNameI] = AT20.AT20NameI,
		[TherpstExternalID] = IFAT_AT20.ExtVal

	FROM PT15
	JOIN PT11(NOLOCK) ON PT11.CorpID = PT15.CorpID 
					 AND PT11.CaseKey = PT15.CaseKey
	JOIN PT10(NOLOCK) ON PT11.CorpID = PT10.CorpID 
					 AND PT11.PatientKey = PT10.PatientKey
	JOIN ST15(NOLOCK) ON PT15.PT15status = ST15.ApptStatusKey
	JOIN AT20(NOLOCK) ON AT20.CorpID = PT15.CorpID 
					 AND AT20.TherpstKey = PT15.TherpstKey
	----------------------------------------
	-- Get RT appointment external data
	JOIN IFLT_ExtSys RTExternalSys (NOLOCK) ON RTExternalSys.CorpID = PT15.CorpID
					 AND RTExternalSys.ExtSysName = @RTExtSysName
	-- Get external Account/CaseID when RMT
	JOIN IFLT_ExtAttr RTATExternalAccIDs (NOLOCK)
			INNER JOIN IFAT_AT11(NOLOCK) ON 
				RTATExternalAccIDs.ExtAttrID = IFAT_AT11.ExtAttrID ON
		RTATExternalAccIDs.CorpID = RTExternalSys.CorpID
		AND RTATExternalAccIDs.ExtSysID = RTExternalSys.ExtSysID
		AND RTATExternalAccIDs.Active = 1
		AND IFAT_AT11.CorpID = PT15.CorpID
		AND IFAT_AT11.ClinicKey = PT15.ClinicKey
	-- Get external TherapistID when RMT
	LEFT JOIN IFLT_ExtAttr RTATExternalTherIDs (NOLOCK)
			INNER JOIN IFAT_AT20(NOLOCK) ON
				RTATExternalTherIDs.ExtAttrID = IFAT_AT20.ExtAttrID ON
		RTATExternalTherIDs.CorpID = RTExternalSys.CorpID
		AND RTATExternalTherIDs.ExtSysID = RTExternalSys.ExtSysID
		AND RTATExternalTherIDs.Active = 1
		AND IFAT_AT20.CorpID = AT20.CorpID
		AND IFAT_AT20.TherpstKey = AT20.TherpstKey
	-- Get external LocationID when RMT
	JOIN IFLT_ExtAttr RTPTExternalIDs (NOLOCK) ON RTPTExternalIDs.CorpID = RTExternalSys.CorpID
					 AND RTPTExternalIDs.ExtSysID = RTExternalSys.ExtSysID
					 AND RTPTExternalIDs.Active = 1
	JOIN IFPT_PT11(NOLOCK) ON IFPT_PT11.CorpID = PT15.CorpID
					AND IFPT_PT11.CaseKey = PT15.CaseKey 
					AND IFPT_PT11.ExtAttrID = RTPTExternalIDs.ExtAttrID

	----------------------------------------
	-- External System for STB - To Allow definition of "Appointment Types"
	JOIN IFLT_ExtSys SBCExternalSys (NOLOCK) ON SBCExternalSys.CorpID = PT15.CorpID 
			AND SBCExternalSys.ExtSysName = @SBCExtSysName
	JOIN IFLT_ExtAttr SBCExternalIDs (NOLOCK) ON SBCExternalIDs.CorpID = SBCExternalSys.CorpID 
			AND SBCExternalIDs.ExtSysID = SBCExternalSys.ExtSysID 
			AND SBCExternalIDs.Active = 1
			-- IF Using External AT95 attribute configuration
			AND SBCExternalIDs.ExtAttrName = @ExtAT95Attribute
	JOIN AT95(NOLOCK) ON AT95.CorpID = PT15.CorpID AND AT95.ClinicKey = PT15.ClinicKey 
			AND AT95.ApptTypeKey = PT15.ApptTypeKey
	JOIN IFAT_AT95 SBCApptTypes (NOLOCK) ON SBCApptTypes.CorpID = AT95.CorpID 
			AND SBCApptTypes.ClinicKey = AT95.ClinicKey 
			AND SBCApptTypes.ApptTypeKey = AT95.ApptTypeKey 
			AND SBCApptTypes.ExtAttrID = SBCExternalIDs.ExtAttrID

	----------------------------------------
	WHERE PT15.CorpID = @CorpID
		AND PT15ApptDat BETWEEN @StartDate AND @EndDate
		AND PT10.PtTypeKey = 0 -- Production Patient - ST05 FK 

		-- For what locations ; NULL => ALL
		AND IFAT_AT11.ExtVal = COALESCE(@ExtLocID, IFAT_AT11.ExtVal)

		AND SBCApptTypes.ExtVal = @SBCApptType                 


	SELECT
		[CorpID],
		[CaseKey],
		[ApptSequence],
		[DateOfVisit],
		[ApptTypeDescription],
		[ApptStatusDescription],
		[Comment],
		[ColorCode],
		[ExternalLocationID],
		[ExternalID],
		[TherpstKey],
		[TherpstNameL], 
		[TherpstNameF],
		[TherpstNameI],
		[TherpstExternalID]
	FROM @Appointments
	ORDER BY DateOfVisit

	--------------------------------------------------
	--------------------------------------------------
	-- VARIABLES FOR AUDIT
	DECLARE @ActionID		INT = 2, -- ActionID.Access
			@EventID		INT = 5, -- EventID.Appointment, 
			@ModuleID		INT = 5, -- ModuleID.ADTInboundInterface
			@ClinicKey		SMALLINT,
			@CaseID			VARCHAR(20),
			@CaseKey		VARCHAR(10),
			@RecordID		VARCHAR(20),
			@PatientKey		VARCHAR(10),
			@RecordName		VARCHAR(200),
			@PT10NameF		VARCHAR(30),
			@PT10NameL		VARCHAR(30),
			@PT10NameI		CHAR(1)


	DECLARE @CursorStatus SMALLINT
	SELECT @CursorStatus = CURSOR_STATUS('global','AppCursor')

	IF (@CursorStatus IN (0, 1))
	BEGIN
		CLOSE AppCursor
		DEALLOCATE AppCursor
	END
	ELSE 
		IF @CursorStatus = -1
		BEGIN
			DEALLOCATE AppCursor
		END

	DECLARE AppCursor CURSOR
	STATIC LOCAL FORWARD_ONLY FOR
	SELECT DISTINCT
		ClinicKey,
		CaseKey,
		PatientKey,
		PT10NameF,
		PT10NameL,
		PT10NameI
	FROM @Appointments                

	OPEN AppCursor
	FETCH NEXT FROM AppCursor
	INTO
		@ClinicKey,
		@CaseKey,
		@PatientKey,
		@PT10NameF,
		@PT10NameL,
		@PT10NameI

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	    
		SET @CaseID	= RIGHT('0000' + CAST(@CorpID AS VARCHAR(4)),4) + CAST(@CaseKey AS VARCHAR(10))
		SET @RecordID = RIGHT('0000' + CAST(@CorpID AS VARCHAR(4)),4) + CAST(@PatientKey AS VARCHAR(10))
	    
		IF RTRIM(@PT10NameI) IS NULL
			SET @RecordName = RTRIM(@PT10NameL) + ', ' + RTRIM(@PT10NameF)
		ELSE
			SET @RecordName =  RTRIM(@PT10NameL) + ', '  + RTRIM(@PT10NameF) + ' ' + + @PT10NameI + '.'		
	    
		EXEC PT_CreateAudit @ActionID	= @ActionID,
							@EventID	= @EventID,
							@ModuleID	= @ModuleID,
							@OutcomeID	= 1,-- OutcomeID.Success
							@CorpID		= @CorpID,
							@ClinicKey	= @ClinicKey,
							@CaseID		= @CaseID,
							@RecordID	= @RecordID,
							@RecordName	= @RecordName,
							@Screen		= NULL,
							@Printer	= NULL,
							@UserID		= @UserID,
							@MachineName = @MachineName

		FETCH NEXT FROM AppCursor
		INTO
			@ClinicKey,
			@CaseKey,
			@PatientKey,
			@PT10NameF,
			@PT10NameL,
			@PT10NameI
	END

	CLOSE AppCursor
	DEALLOCATE AppCursor
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        -- Roll back complete transaction.
        ROLLBACK TRANSACTION;

	EXEC PT_CreateAudit @ActionID	= @ActionID,
						@EventID	= @EventID,
						@ModuleID	= @ModuleID,
						@OutcomeID	= 2,-- OutcomeID.Fail
						@CorpID		= @CorpID,
						@ClinicKey	= @ClinicKey,
						@CaseID		= @CaseID,
						@RecordID	= @RecordID,
						@RecordName	= @RecordName,
						@Screen		= NULL,
						@Printer	= NULL,
						@UserID		= @UserID,
						@MachineName = @MachineName
								
    -- After the rollback, echo error
    -- information to the caller.
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorNumber = ERROR_NUMBER();
    SELECT @ErrorSeverity = ERROR_SEVERITY();
    SELECT @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorNumber, -- Message number.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH

GO

if exists (select * from sysobjects where id = object_id(N'dbo.WebAPI_SBC_UpdateAppointment') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WebAPI_SBC_UpdateAppointment
go

/**************************************************************************
 * Proc Name:     WebAPI_SBC_UpdateAppointment
 * 
 * Purpose:       Updates appointment for SBC API.
 * 
 * Rules:         
 * 
 * Parameters:    CorpID		INT	- Corporation identifier.
 *                UserName		VARCHAR(100)  - The user id who performs this operation.
 *				  MachineName	VARCHAR(200) - Machine name where SBC API is running.
 *                CaseKey		INT	- Appointment case key.
 *                ApptSeq		INT - Appointment sequence number that uniquely identifies appointment in a case.
 *                Comment		VARCHAR (200) - Insurance verification comment.
 *												Will be inserted before the existing comments for the patient and appointment.
 *                ApptColor		INT - Color for insurance verification represented as .NET Framework Color structure
 *									  (will be converted to OLE color format to store in TS database).
 *									  Will be null if color is not specified for the appointment.
 * 
 * Returns:       
 * 
 * Called By:	  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROCEDURE dbo.WebAPI_SBC_UpdateAppointment
    @CorpID         INT,
    @UserName       VARCHAR(100),
    @MachineName	VARCHAR(200),
    @CaseKey        INT,
    @ApptSeq        INT,
    @Comment        VARCHAR (2000),
    @ApptColor      INT
AS

DECLARE @RetCode INT

-- Validate the user.
EXEC @RetCode = ValidateUser @CorpID, @UserName
IF @RetCode <> 1 
BEGIN
    RAISERROR(51300,16,1)
    RETURN
END

DECLARE @UpdatePT10    BIT -- Update Patient Patients Table (patient comments)
        , @UpdatePT11  BIT -- Update Patient Cases Table (insurance comments)
        , @UpdatePT15  BIT  -- Update Patient Appointments Table
	
SELECT @UpdatePT10  = 1
       , @UpdatePT11  = 0
       , @UpdatePT15  = 1
	
DECLARE @FormattedComment   VARCHAR(2000)
        , @SBCExtSysName    VARCHAR(30)
        , @SBCExtAttrName   VARCHAR(30)


SELECT @FormattedComment    =  @Comment
        , @SBCExtSysName    = 'SBC'
        , @SBCExtAttrName   = 'IsVerified'

IF EXISTS (
	SELECT 1
	FROM PT15 
	WHERE 
		PT15.CorpID  = @CorpID
		AND PT15.CaseKey = @CaseKey
		AND PT15.ApptSeq = @ApptSeq
	)
BEGIN TRY
	BEGIN TRANSACTION;
		
	------------------------------------------------------------
	------------------------------------------------------------
	IF @UpdatePT15 = 1 
	BEGIN

		UPDATE PT15 
			SET PT15.PT15Comment = LEFT((@FormattedComment + COALESCE(CHAR(13) + CHAR(10)+ PT15.PT15Comment, '')),2000),
				PT15.PT15ApptColor = @ApptColor
		FROM PT15
		WHERE PT15.CorpID  = @CorpID
		  AND PT15.CaseKey = @CaseKey
		  AND PT15.ApptSeq = @ApptSeq
	    
		-- ???
		-- 2013/07/29 Add Update to IFPT_PT15 on custom external attribute
		--            Pending functional decision from Product Team
		-- IFPT_PT15 -> IFLT_ExtAttr (particular attribute)

		/*
		UPDATE IFPT_PT15
			SET ExtVal = @Verified
		FROM IFPT_PT15 
		JOIN IFLT_ExtSys  SBCExtSys ON SBCExtSys.CorpID  = @CorpID
					AND SBCExtSys.Name = @SBCExtSysName
		JOIN IFLT_ExtAttr SBCExtAttr ON SBCExtSys.CorpID  = @CorpID
					AND SBCExtSys.ExtSysID  = SBCExtAttr.ExtSysID
					AND SBCExtAttr.Name = @SBCExtAttrName 
		WHERE IFPT_PT15.CorpID  = @CorpID
		  AND IFPT_PT15.CaseKey = @CaseKey
		  AND IFPT_PT15.ApptSeq = @ApptSeq
		  AND IFPT_PT15.ExtAttrID = SBCExtAttr.ExtAttrID 
		  */
	   
	END


	------------------------------------------------------------
	------------------------------------------------------------
	IF @UpdatePT10 = 1 
	BEGIN

		-- Patient Comments - 
		UPDATE PT10 
			SET PT10.PT10Text = LEFT ((@FormattedComment + COALESCE(CHAR(13) + CHAR(10) + PT10.PT10Text, '')),2000),
				PT10.PT10ChgID = @UserName
		FROM PT15
			JOIN PT11 ON PT15.CorpID = PT11.CorpID and PT15.CaseKey = PT11.CaseKey 
			JOIN PT10 ON PT11.CorpID = PT10.CorpID and PT11.PatientKey = PT10.PatientKey
		WHERE PT15.CorpID  = @CorpID
		  AND PT15.CaseKey = @CaseKey
		  AND PT15.ApptSeq = @ApptSeq
	    
	END
	    

	------------------------------------------------------------
	------------------------------------------------------------
	IF @UpdatePT11 = 1 
	BEGIN

		-- Insurance Comments
		UPDATE PT11 
			SET PT11.PT11BusComments =  LEFT ((@FormattedComment + COALESCE(CHAR(13) + CHAR(10) + PT11.PT11BusComments, '')),2000),
				PT11.PT11ChgID = @UserName
		FROM PT15
			JOIN PT11 ON PT15.CorpID = PT11.CorpID and PT15.CaseKey = PT11.CaseKey 
		WHERE PT15.CorpID  = @CorpID
		  AND PT15.CaseKey = @CaseKey
		  AND PT15.ApptSeq = @ApptSeq
	    
	END

	-- VARIABLES FOR AUDIT
	DECLARE @ActionID		INT = 3, -- ActionID.Modify
			@EventID		INT = 5, -- EventID.Appointment, 
			@ModuleID		INT = 5, -- ModuleID.ADTInboundInterface
			@ClinicKey		SMALLINT,
			@CaseID			VARCHAR(20),
			@RecordID		VARCHAR(20),
			@PatientKey		VARCHAR(10),
			@RecordName		VARCHAR(200),
			@PT10NameF		VARCHAR(30),
			@PT10NameL		VARCHAR(30),
			@PT10NameI		CHAR(1)
			
	SELECT
		@PatientKey = PT10.PatientKey,
		@PT10NameF	= PT10.PT10NameF,
		@PT10NameL	= PT10.PT10NameL,
		@PT10NameI	= PT10.PT10NameI,
		@ClinicKey	= PT15.ClinicKey
	FROM PT15
		JOIN PT11 ON PT15.CorpID = PT11.CorpID and PT15.CaseKey = PT11.CaseKey 
		JOIN PT10 ON PT11.CorpID = PT10.CorpID and PT11.PatientKey = PT10.PatientKey
	WHERE PT15.CorpID  = @CorpID
	  AND PT15.CaseKey = @CaseKey
	  AND PT15.ApptSeq = @ApptSeq
		
	SET @CaseID	= RIGHT('0000' + CAST(@CorpID AS VARCHAR(4)),4) + CAST(@CaseKey AS VARCHAR(10))
	SET @RecordID = RIGHT('0000' + CAST(@CorpID AS VARCHAR(4)),4) + CAST(@PatientKey AS VARCHAR(10))
    
	IF RTRIM(@PT10NameI) IS NULL
		SET @RecordName = RTRIM(@PT10NameL) + ', ' + RTRIM(@PT10NameF)
	ELSE
		SET @RecordName =  RTRIM(@PT10NameL) + ', '  + RTRIM(@PT10NameF) + ' ' + + @PT10NameI + '.'		
    
	EXEC PT_CreateAudit @ActionID	= @ActionID,
						@EventID	= @EventID,
						@ModuleID	= @ModuleID,
						@OutcomeID	= 1,-- OutcomeID.Success
						@CorpID		= @CorpID,
						@ClinicKey	= @ClinicKey,
						@CaseID		= @CaseID,
						@RecordID	= @RecordID,
						@RecordName	= @RecordName,
						@Screen		= NULL,
						@Printer	= NULL,
						@UserID		= @UserName,
						@MachineName = @MachineName


    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        -- Roll back complete transaction.
        ROLLBACK TRANSACTION;

	EXEC PT_CreateAudit @ActionID	= @ActionID,
							@EventID	= @EventID,
							@ModuleID	= @ModuleID,
							@OutcomeID	= 2,-- OutcomeID.Fail
							@CorpID		= @CorpID,
							@ClinicKey	= @ClinicKey,
							@CaseID		= @CaseID,
							@RecordID	= @RecordID,
							@RecordName	= @RecordName,
							@Screen		= NULL,
							@Printer	= NULL,
							@UserID		= @UserName,
							@MachineName = @MachineName
							
    -- After the rollback, echo error
    -- information to the caller.
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorNumber = ERROR_NUMBER();
    SELECT @ErrorSeverity = ERROR_SEVERITY();
    SELECT @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorNumber, -- Message number.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH
GO

if exists (select * from sysobjects where id = object_id(N'dbo.WebAPI_SBC_GetTSUsers') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WebAPI_SBC_GetTSUsers
go

/**************************************************************************
 * Proc Name:     dbo.WebAPI_SBC_GetTSUsers
 * 
 * Purpose:       Return the list of all users (active and inactive) for SBC API.
 * 
 * Rules:         
 * 
 * Parameters:    CorpID		INT			 - Corporation identifier.
 *                UserID		VARCHAR(100) - The username who performs this operation.
 *				  ThrpstKey		INT			 - User ID (therapist key) in TS to get data.
 * 
 * Returns:       List of users from TS system.
 * 
 * Called By:	  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/
GO

CREATE PROCEDURE dbo.WebAPI_SBC_GetTSUsers
    @CorpID         INT,
    @UserID         VARCHAR(100),
	@ThrpstKey		INT = NULL
AS

DECLARE @RetCode INT

-- Validate the user.
EXEC @RetCode = ValidateUser @CorpID, @UserID
IF @RetCode <> 1 
BEGIN
    RAISERROR(51300,16,1)
    RETURN
END

DECLARE @ClinicCount INT
SET @ClinicCount = (SELECT COUNT(*) FROM dbo.AT11 WHERE CorpID = @CorpID)

BEGIN TRY
	BEGIN TRANSACTION;
	
	-- TSUserInfo
    SELECT
		U.TherpstKey,
		U.AT20NameF AS FirstName,
		U.AT20NameL AS LastName,
		U.AT20NameI AS MiddleInitial,
		U.AT20UID AS DomainUser,
		U.AT20SSN AS SSN,
		U.AT20BDay AS DateOfBirth,
		U.AT20Active AS Active,
		U.AT20TStamp AS EntityTimeStamp
    FROM dbo.AT20 AS U
    WHERE
		U.CorpID = @CorpID
		AND (U.TherpstKey = @ThrpstKey OR @ThrpstKey IS NULL)
		
	-- TSUserClinicRoleInfo
	SELECT
		U.TherpstKey,
		M.MedSpecKey,
		M.LT18Abrev
	FROM
		dbo.AT20 AS U
		LEFT JOIN (
			SELECT 
				CorpID,
				TherpstKey,
				MedSpecKey,
				COUNT(ClinicKey) AS ClinicCount
			FROM dbo.AT21
			WHERE CorpID = @CorpID
			GROUP BY
				CorpID,
				TherpstKey,
				MedSpecKey
			HAVING COUNT(ClinicKey) <> @ClinicCount
			) AS ER
			ON ER.CorpID = U.CorpID
			AND ER.TherpstKey = U.TherpstKey
		INNER JOIN (
			SELECT DISTINCT
				CorpID,
				TherpstKey,
				MedSpecKey
			FROM dbo.AT21
			) AS R
			ON R.CorpID = U.CorpID
			AND R.TherpstKey = U.TherpstKey
		LEFT JOIN dbo.LT18 AS M
			ON M.MedSpecKey = R.MedSpecKey
    WHERE
		U.CorpID = @CorpID
		AND (U.TherpstKey = @ThrpstKey OR @ThrpstKey IS NULL)
		AND ER.TherpstKey IS NULL
	
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        -- Roll back complete transaction.
        ROLLBACK TRANSACTION;
								
    -- After the rollback, echo error
    -- information to the caller.
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorNumber = ERROR_NUMBER();
    SELECT @ErrorSeverity = ERROR_SEVERITY();
    SELECT @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorNumber, -- Message number.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH

GO

if exists (select * from sysobjects where id = object_id(N'dbo.WebAPI_SBC_CreateTSUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WebAPI_SBC_CreateTSUser
go

/**************************************************************************
 * Proc Name:     dbo.WebAPI_SBC_CreateTSUser
 * 
 * Purpose:       Creates user in TS system.
 * 
 * Rules:         
 * 
 * Parameters:    CorpID			INT			 - Corporation identifier.
 *                UserID			VARCHAR(100) - The username who performs this operation.
 *				  ThrpstKey			INT			 - User ID (therapist key) in TS.
 *				  FirstName			VARCHAR(30)  - First Name of this therapist.
 *				  LastName			VARCHAR(30)	 - Last Name of this therapist.
 *				  MiddleInitial		CHAR(1)		 - Middle Initial of this therapist.
 *				  DomainUser		VARCHAR(100) - NT User ID of this therapist.
 *				  SSN				CHAR(9)		 - SSN of this therapist.
 *				  DateOfBirth		DATETIME	 - Date of birth.
 *				  Active			BIT			 - Flag indicating whether user is active or not.
 * 
 * Returns:       
 * 
 * Called By:	  SBC API
 * 
 * Calls:
 *
 * Notes: The entity ID is sent to the service in the entity object.
 *		  Service caller is responsible for generating unique ID for creating new record.
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROCEDURE dbo.WebAPI_SBC_CreateTSUser
    @CorpID				INT,
    @UserID				VARCHAR(100),
	@ThrpstKey			INT,
	@FirstName			VARCHAR(30),
	@LastName			VARCHAR(30),
	@MiddleInitial		CHAR(1),
	@DomainUser			VARCHAR(100),
	@SSN				CHAR(9),
	@DateOfBirth		DATETIME,
	@Active				BIT
	
AS

DECLARE @RetCode INT

-- Validate the user.
EXEC @RetCode = ValidateUser @CorpID, @UserID
IF @RetCode <> 1 
BEGIN
    RAISERROR(51300,16,1)
    RETURN
END

DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;
BEGIN TRY	

	IF EXISTS(
		SELECT 1
		FROM dbo.AT20
		WHERE
			CorpID = @CorpID
			AND TherpstKey = @ThrpstKey
	)
	RAISERROR (50104, 16, 1)

	INSERT INTO dbo.AT20 (
		CorpID,
		TherpstKey,
		AT20NameF,
		AT20NameL,
		AT20NameI,
		AT20UID,
		AT20SSN,
		AT20BDay,
		AT20Active
	)
	VALUES (
		@CorpID,
		@ThrpstKey,
		@FirstName,
		@LastName,
		@MiddleInitial,
		@DomainUser,
		@SSN,
		@DateOfBirth,
		@Active
	)

   IF @TranCounter = 0
        COMMIT TRANSACTION;

END TRY
BEGIN CATCH
        IF @TranCounter = 0
            ROLLBACK TRANSACTION;
        ELSE
            IF XACT_STATE() <> -1
                ROLLBACK TRANSACTION ProcedureSave;
								
    -- After the rollback, echo error
    -- information to the caller.
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorNumber = ERROR_NUMBER();
    SELECT @ErrorSeverity = ERROR_SEVERITY();
    SELECT @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorNumber, -- Message number.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH
GO

if exists (select * from sysobjects where id = object_id(N'dbo.WebAPI_SBC_CreateTSUserRole') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WebAPI_SBC_CreateTSUserRole
go

/**************************************************************************
 * Proc Name:     dbo.WebAPI_SBC_CreateTSUserRole
 * 
 * Purpose:       Assigns role to user in all existing clinics in TS system.
 * 
 * Rules:         
 * 
 * Parameters:    CorpID			INT			 - Corporation identifier.
 *                UserID			VARCHAR(100) - The username who performs this operation.
 *				  ThrpstKey			INT			 - User ID (therapist key) in TS.
 *				  RoleName			VARCHAR(20)	 - User’s role abbreviation.
 * 
 * Returns:       
 * 
 * Called By:	  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROCEDURE dbo.WebAPI_SBC_CreateTSUserRole
    @CorpID				INT,
    @UserID				VARCHAR(100),
	@ThrpstKey			INT,
	@RoleName			VARCHAR(20)
AS

DECLARE @RetCode INT

-- Validate the user.
EXEC @RetCode = ValidateUser @CorpID, @UserID
IF @RetCode <> 1 
BEGIN
    RAISERROR(51300,16,1)
    RETURN
END

BEGIN TRY
	BEGIN TRANSACTION

	IF NOT EXISTS(
		SELECT 1
		FROM dbo.AT20
		WHERE
			CorpID = @CorpID
			AND TherpstKey = @ThrpstKey
	)
	RAISERROR (50102, 16, 1)

	DECLARE @MedSpecKey INT
	SET @MedSpecKey = (SELECT TOP 1 MedSpecKey FROM dbo.LT18 WHERE LT18Abrev = @RoleName)

	INSERT INTO dbo.AT21 (
		CorpID,
		ClinicKey,
		TherpstKey,
		MedSpecKey
	)
	SELECT
		@CorpID,
		ClinicKey,
		@ThrpstKey,
		@MedSpecKey
	FROM dbo.AT11
	WHERE CorpID = @CorpID
	
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        -- Roll back complete transaction.
        ROLLBACK TRANSACTION;
								
    -- After the rollback, echo error
    -- information to the caller.
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorNumber = ERROR_NUMBER();
    SELECT @ErrorSeverity = ERROR_SEVERITY();
    SELECT @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorNumber, -- Message number.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH
GO

if exists (select * from sysobjects where id = object_id(N'dbo.WebAPI_SBC_DeleteTSUserRoles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WebAPI_SBC_DeleteTSUserRoles
go

/**************************************************************************
 * Proc Name:     dbo.WebAPI_SBC_DeleteTSUserRoles
 * 
 * Purpose:       Delete all user's roles from all existing clinics in TS system.
 * 
 * Rules:         
 * 
 * Parameters:    CorpID			INT			 - Corporation identifier.
 *                UserID			VARCHAR(100) - The username who performs this operation.
 *				  ThrpstKey			INT			 - User ID (therapist key) in TS.
 * 
 * Returns:       
 * 
 * Called By:	  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROCEDURE dbo.WebAPI_SBC_DeleteTSUserRoles
    @CorpID				INT,
    @UserID				VARCHAR(100),
	@ThrpstKey			INT
AS

DECLARE @RetCode INT

-- Validate the user.
EXEC @RetCode = ValidateUser @CorpID, @UserID
IF @RetCode <> 1 
BEGIN
    RAISERROR(51300,16,1)
    RETURN
END

BEGIN TRY
	BEGIN TRANSACTION

	IF NOT EXISTS(
		SELECT 1
		FROM dbo.AT20
		WHERE
			CorpID = @CorpID
			AND TherpstKey = @ThrpstKey
	)
	RAISERROR (50102, 16, 1)

	DELETE FROM dbo.AT21
	WHERE
		CorpID = @CorpID
		AND TherpstKey = @ThrpstKey
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        -- Roll back complete transaction.
        ROLLBACK TRANSACTION;
								
    -- After the rollback, echo error
    -- information to the caller.
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorNumber = ERROR_NUMBER();
    SELECT @ErrorSeverity = ERROR_SEVERITY();
    SELECT @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorNumber, -- Message number.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH
GO

if exists (select * from sysobjects where id = object_id(N'dbo.WebAPI_SBC_UpdateTSUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WebAPI_SBC_UpdateTSUser
go

/**************************************************************************
 * Proc Name:     dbo.WebAPI_SBC_UpdateTSUser
 * 
 * Purpose:       Updates user in TS system.
 * 
 * Rules:         
 * 
 * Parameters:    CorpID			INT			 - Corporation identifier.
 *                UserID			VARCHAR(100) - The username who performs this operation.
 *				  ThrpstKey			INT			 - User ID (therapist key) in TS.
 *				  FirstName			VARCHAR(30)  - First Name of this therapist.
 *				  LastName			VARCHAR(30)	 - Last Name of this therapist.
 *				  MiddleInitial		CHAR(1)		 - Middle Initial of this therapist.
 *				  DomainUser		VARCHAR(100) - NT User ID of this therapist.
 *				  SSN				CHAR(9)		 - SSN of this therapist.
 *				  DateOfBirth		DATETIME	 - Date of birth.
 *				  Active			BIT			 - Flag indicating whether user is active or not.
 *				  EntityTimeStamp	TIMESTAMP	 - The timestamp (in binary format) when the version of the entity was loaded to the SBC,
 *												   used for optimistic concurrency check.
 * 
 * Returns:       
 * 
 * Called By:	  SBC API
 * 
 * Calls:
 *
 * Notes: The entity ID is sent to the service in the entity object.
 *		  Service caller is responsible for generating unique ID for creating new record.
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROCEDURE dbo.WebAPI_SBC_UpdateTSUser
    @CorpID				INT,
    @UserID				VARCHAR(100),
	@ThrpstKey			INT,
	@FirstName			VARCHAR(30),
	@LastName			VARCHAR(30),
	@MiddleInitial		CHAR(1),
	@DomainUser			VARCHAR(100),
	@SSN				CHAR(9),
	@DateOfBirth		DATETIME,
	@Active				BIT,
	@EntityTimeStamp	TIMESTAMP
	
AS

DECLARE @RetCode INT

-- Validate the user.
EXEC @RetCode = ValidateUser @CorpID, @UserID
IF @RetCode <> 1 
BEGIN
    RAISERROR(51300,16,1)
    RETURN
END

BEGIN TRY
	BEGIN TRANSACTION
	
	IF NOT EXISTS(
		SELECT 1
		FROM dbo.AT20
		WHERE
			CorpID = @CorpID
			AND TherpstKey = @ThrpstKey
	)
	RAISERROR (50102, 16, 1)

	IF EXISTS (
		SELECT 1
		FROM dbo.AT20
		WHERE
			CorpID = @CorpID
			AND TherpstKey = @ThrpstKey
			AND AT20TStamp > @EntityTimeStamp
	)
	RAISERROR (50101, 16, 1)

	UPDATE dbo.AT20
		SET AT20NameF = @FirstName,
		AT20NameL	= @LastName,
		AT20NameI	= @MiddleInitial,
		AT20UID		= @DomainUser,
		AT20SSN		= @SSN,
		AT20BDay	= @DateOfBirth,
		AT20Active	= @Active
	WHERE
		CorpID = @CorpID
		AND TherpstKey = @ThrpstKey
		
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        -- Roll back complete transaction.
        ROLLBACK TRANSACTION;
								
    -- After the rollback, echo error
    -- information to the caller.
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorNumber = ERROR_NUMBER();
    SELECT @ErrorSeverity = ERROR_SEVERITY();
    SELECT @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorNumber, -- Message number.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH
GO

/**************************************************************************
 * External Settings
 ***************************************************************************/

DECLARE @CorpID INT
DECLARE @CurrDate DATETIME = GETDATE()
DECLARE @SysDisplayName VARCHAR(30) = 'SBC'
DECLARE @ExtSysName VARCHAR(50) = 'SBC'
DECLARE @ExtSysID INT

DECLARE @ExtAttrName VARCHAR(512) = 'AT95/ExtApptTypeId'
DECLARE @AttrDisplayName VARCHAR(30) = 'Appointment Type'


BEGIN TRAN
	
	DECLARE @CursorStatus SMALLINT
	SELECT @CursorStatus = CURSOR_STATUS('global','CorpCursor')

	IF (@CursorStatus IN (0, 1))
	BEGIN
		CLOSE CorpCursor
		DEALLOCATE CorpCursor
	END
	ELSE 
		IF @CursorStatus = -1
		BEGIN
			DEALLOCATE CorpCursor
		END

	DECLARE CorpCursor CURSOR
	STATIC LOCAL FORWARD_ONLY FOR
	SELECT DISTINCT
		CorpID
	FROM dbo.ST02

	OPEN CorpCursor
	FETCH NEXT FROM CorpCursor
	INTO
		@CorpID

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	    
		-- dbo.IFLT_ExtSys table
		IF NOT EXISTS (
			SELECT 1
			FROM dbo.IFLT_ExtSys
			WHERE
				DisplayName = @SysDisplayName
				AND ExtSysName = @ExtSysName
				AND CorpID = @CorpID
		)
		BEGIN
		INSERT INTO dbo.IFLT_ExtSys (
				CorpID,
				DisplayName,
				ExtSysName,
				ExtSysDesc,
				Active,
				LastChgDat,
				LastChgUserID,
				SendADTRegisterMessage,
				SendADTUpdateMessage
			)
			VALUES (
				@CorpID,
				@SysDisplayName,
				@ExtSysName,
				NULL,
				1,
				@CurrDate,
				'TSDEMO\client',
				0,
				0
			)
		END
		
		SET @ExtSysID = (
			SELECT TOP 1 ExtSysID
			FROM dbo.IFLT_ExtSys
			WHERE
				DisplayName = @SysDisplayName
				AND ExtSysName = @ExtSysName
				AND CorpID = @CorpID
		)
		

		-- dbo.IFLT_ExtAttr table
		IF NOT EXISTS (
			SELECT 1
			FROM dbo.IFLT_ExtAttr
			WHERE
				ExtAttrName = @ExtAttrName
				AND ExtSysID = @ExtSysID
				AND CorpID = @CorpID
		)
		BEGIN
			INSERT INTO dbo.IFLT_ExtAttr(
				ExtSysID,
				CorpID,
				DisplayName,
				ExtAttrKey,
				TSEntity,
				ExtAttrName,
				Mask,
				FixLength,
				MaxVal,
				Active,
				LastChgDat,
				LastChgUserID
			)
			VALUES (
				@ExtSysID,
				@CorpID,
				@AttrDisplayName,
				0,
				'AT95',
				@ExtAttrName,
				'@@',
				0,
				NULL,
				1,
				@CurrDate,
				'TSDEMO\client'
			)
		END


		FETCH NEXT FROM CorpCursor
		INTO
			@CorpID
	END

	CLOSE CorpCursor
	DEALLOCATE CorpCursor

IF @@ERROR = 0
	COMMIT TRAN
ELSE
	ROLLBACK TRAN