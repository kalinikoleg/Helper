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

-- Add error message for related data not found exception
IF EXISTS (
	SELECT 1
	FROM sys.messages
	WHERE
	message_id = 50103
)
EXEC sp_dropmessage @msgnum = 50103, @lang = 'all';
GO

EXEC sp_addmessage 50103, 16, 'Related data not found'
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

-- Add error message for record cannot be deleted exception
IF EXISTS (
	SELECT 1
	FROM sys.messages
	WHERE
	message_id = 50105
)
EXEC sp_dropmessage @msgnum = 50105, @lang = 'all';
GO

EXEC sp_addmessage 50105, 16, 'Record cannot be deleted'
GO

-- Add error message for related data duplicate exception
IF EXISTS (
	SELECT 1
	FROM sys.messages
	WHERE
	message_id = 50106
)
EXEC sp_dropmessage @msgnum = 50106, @lang = 'all';
GO

EXEC sp_addmessage 50106, 16, 'Related data duplicate'
GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_Collectors') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_Collectors

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_SELECT_Collectors
 * 
 * Purpose:       Returns the list of collectors information for SBC API.
 * 
 * Rules:
 * 
 * Parameters:    UserID		VARCHAR(255)  - The user id who performs this operation.
 *				  CollectorID	VARCHAR(10)	  - Collector identifier.
 * 
 * Returns:       List of collectors information.
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

CREATE PROC dbo.usp_SBC_SELECT_Collectors
    @UserID			VARCHAR(255),
    @CollectorID	VARCHAR(10) = NULL
AS

SELECT CollectorID,
       CollectorName,
       Initials
FROM   tblCollector
WHERE CollectorID = @CollectorID OR @CollectorID IS NULL

GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_Collector') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_CREATE_Collector

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_CREATE_Collector
 * 
 * Purpose:       Creates collector data in RT system.
 * 
 * Rules:         
 * 
 * Parameters:    UserID		VARCHAR(255)  - The user id who performs this operation.
 *				  CollectorID	VARCHAR(10)	  - Collector identifier.
 *				  CollectorName	VARCHAR(50)	  - Collector name.
 *				  Initials		VARCHAR(5)	  - Collector initials.
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

CREATE PROC dbo.usp_SBC_CREATE_Collector
    @UserID			VARCHAR(255),
    @CollectorID	VARCHAR(10),
    @CollectorName	VARCHAR(50),
    @Initials		VARCHAR(5)
AS

BEGIN TRY
	BEGIN TRANSACTION;
	
	IF EXISTS(
		SELECT 1
		FROM dbo.tblCollector
		WHERE CollectorID = @CollectorID
	)
	RAISERROR (50104, 16, 1)

	INSERT INTO dbo.tblCollector (
			CollectorID,
			CollectorName,
			Initials
		)
		 VALUES (
			@CollectorID,
			@CollectorName,
			@Initials
		 )
		 
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_UPDATE_Collector') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_UPDATE_Collector

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_UPDATE_Collector
 * 
 * Purpose:       Updates collector data in RT system.
 * 
 * Rules:
 * 
 * Parameters:    UserID		VARCHAR(255)  - The user id who performs this operation.
 *				  CollectorID	VARCHAR(10)	  - Collector identifier.
 *				  CollectorName	VARCHAR(50)	  - Collector name.
 *				  Initials		VARCHAR(5)	  - Collector initials.
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

CREATE PROC dbo.usp_SBC_UPDATE_Collector
    @UserID			VARCHAR(255),
    @CollectorID	VARCHAR(10),
    @CollectorName	VARCHAR(50),
    @Initials		VARCHAR(5)
AS

BEGIN TRY
	BEGIN TRANSACTION
	
	IF NOT EXISTS (
		SELECT 1
		FROM dbo.tblCollector
		WHERE CollectorID = @CollectorID
	)
	RAISERROR (50102, 16, 1)

	UPDATE dbo.tblCollector
	SET
		CollectorName = @CollectorName,
		Initials = @Initials
	WHERE CollectorID = @CollectorID

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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_DELETE_Collector') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_DELETE_Collector

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_DELETE_Collector
 * 
 * Purpose:       Deletes collector data in RT system.
 * 
 * Rules:
 * 
 * Parameters:    UserID		VARCHAR(255)  - The user id who performs this operation.
 *				  CollectorID	VARCHAR(10)	  - Collector identifier.
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

CREATE PROC dbo.usp_SBC_DELETE_Collector
    @UserID			VARCHAR(255),
    @CollectorID	VARCHAR(10)
AS

IF NOT EXISTS (
	SELECT 1
	FROM dbo.tblCollector
	WHERE CollectorID = @CollectorID
)
BEGIN
	RAISERROR (50102, 16, 1)
	RETURN
END

BEGIN TRY
	BEGIN TRANSACTION
	
	DELETE FROM dbo.tblCollector
	WHERE CollectorID = @CollectorID
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
        -- Roll back complete transaction.
        ROLLBACK TRANSACTION;
        
    RAISERROR (50105, 16, 1);
    
END CATCH
GO

if exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_Companies') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_Companies

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_SELECT_Companies
 * 
 * Purpose:       Returns the list of companies for SBC API.
 * 
 * Rules:
 * 
 * Parameters:    UserID    VARCHAR(255) - The user id who performs this operation.
 * 
 * Returns:       List of companies.
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
 
CREATE PROC dbo.usp_SBC_SELECT_Companies
		 @UserID     VARCHAR(255)
AS

SELECT CompanyID,
       CompanyName
FROM   tblCompany

SELECT  DivisionID,
		CompanyId,
        DivisionName
FROM    tblDivision
LEFT JOIN tblCompany ON tblCompany.SysCompanyId = tblDivision.SysCompanyId

SELECT  ProviderID,
		DivisionID,
        ProviderName
FROM    tblProvider
LEFT JOIN tblDivision ON tblDivision.SysDivisionId = tblProvider.SysDivisionId

SELECT  LocationID,
		ProviderID,
		POSID,
		TOSID,
		FeesID,
		FacilityType,
		RegionID,
		CountyID,
		LocationName,
 	    tblLocation.AddressLine1,
		tblLocation.AddressLine2,
		tblLocation.ZipCode,
		tblLocation.City,
		tblLocation.State,
		tblLocation.Phone,
		tblLocation.Fax,
		tblLocation.FedTaxID,
		IsFacilityBilling,
		tblLocation.Deactivated,
		tblLocation.MedicaidProvNumber,
		tblLocation.MedicareProvNumber,
		tblLocation.BCBSNumber,
		tblLocation.NationalPIN
FROM    tblLocation
LEFT JOIN tblPOS ON tblLocation.SysPOSId = tblPOS.SysPOSId
LEFT JOIN tblTOS ON tblLocation.SysTOSId = tblTOS.SysTOSId
LEFT JOIN tblFeeSchedule ON tblLocation .SysFeeScheduleID = tblFeeSchedule.SysFeeScheduleID
LEFT JOIN tblProvider ON tblLocation.SysProviderId  = tblProvider.SysProviderId 

GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_Departments') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_Departments

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_SELECT_Departments
 * 
 * Purpose:       Returns the list of departments for SBC API.
 * 
 * Rules:         
 * 
 * Parameters:    UserID    VARCHAR(255)  - The user id who performs this operation.
 * 
 * Returns:       List of departments.
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

CREATE PROCEDURE dbo.usp_SBC_SELECT_Departments
    @UserID     VARCHAR(255)
AS
SELECT  DepartmentID,
	    Description,
	    Abbreviation
FROM    tblDepartment
WHERE ISNULL (Deactivated , 0) = 0

GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_Insurances') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_Insurances

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_SELECT_Insurances
 * 
 * Purpose:       Returns the list of insurances for SBC API.
 * 
 * Rules:
 * 
 * Parameters:    UserID    VARCHAR(255)  - The user id who performs this operation.
 * 
 * Returns:       List of insurances.
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

CREATE PROCEDURE dbo.usp_SBC_SELECT_Insurances
    @UserID     VARCHAR(255)
AS
SELECT  InsuranceID,
		InsuranceName,
		Phone,
		AddressLine1 AS Address1,
		AddressLine2 AS Address2,
		Zip AS ZipCode,
		City,
		[State]
FROM    tblInsurance

GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_SystemTableDetails') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_SystemTableDetails

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_SELECT_SystemTableDetails
 * 
 * Purpose:       Returns the list of system table information for SBC API.
 * 
 * Rules:         
 * 
 * Parameters:    TablesID  VARCHAR(60)  - Table identifier.
 *				  UserID    VARCHAR(255) - The user id who performs this operation.
 * 
 * Returns:       List of system table information.
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

CREATE PROC dbo.usp_SBC_SELECT_SystemTableDetails
	@TablesID	VARCHAR(60),
    @UserID     VARCHAR(255)
AS
SELECT Code,
       CodeDescription,
       OptionalInfo
FROM   tblSystemTableDetails
JOIN   tblSystemTables 
ON dbo.tblSystemTableDetails.SysTablesID = dbo.tblSystemTables.SysTablesID
WHERE  tblSystemTables.TablesID = @TablesID

GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_DELETE_InsuranceMissingInfo') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.usp_SBC_DELETE_InsuranceMissingInfo

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_DELETE_InsurenceMissingInfo
 * 
 * Purpose:       Removes the insurance missing information items by Insurance identifier.
 * 
 * Rules:         
 * 
 * Parameters:   @InsuranceID		VARCHAR(60)  - Insurance identifier
 *				 @UserID			VARCHAR(255) - The user id of user who performs this operation.
 * Returns:      None
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
CREATE PROC dbo.usp_SBC_DELETE_InsuranceMissingInfo
@InsuranceID	VARCHAR(10),
@UserID			VARCHAR(255)
AS
BEGIN TRY
	DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;

		DECLARE @SysInsuranceID INT
			Set @SysInsuranceID = (SELECT tblInsurance.SysInsuranceId FROM dbo.tblInsurance WHERE tblInsurance.InsuranceID = @InsuranceID)
			
		IF @SysInsuranceID IS NULL
			RAISERROR (50103, 16, 1)

		DELETE FROM dbo.tblInsurance_MissingInformation
			WHERE SysInsuranceId = @SysInsuranceID

	 IF @TranCounter = 0
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


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_InsuranceMissingInfo') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.usp_SBC_CREATE_InsuranceMissingInfo

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_CREATE_InsuranceMissingInfo
 * 
 * Purpose:       Removes the insurance missing information items by Insurance identifier.
 * 
 * Rules:         
 * 
 * Parameters:   @InsuranceID		VARCHAR(60)  - Insurance identifier.
 *				 @RequiredField 	VARCHAR(max) - Insurance required field.
 *				 @UserID			VARCHAR(255) - The user id of user who performs this operation.
 * Returns:      None
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

CREATE PROC dbo.usp_SBC_CREATE_InsuranceMissingInfo
@InsuranceID		VARCHAR(10),
@RequiredField		VARCHAR(24),
@UserID				VARCHAR(255)
AS
	
BEGIN TRY
	DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;

	DECLARE @SysInsuranceID INT
		SET @SysInsuranceID = (SELECT tblInsurance.SysInsuranceId FROM dbo.tblInsurance WHERE tblInsurance.InsuranceID = @InsuranceID)
	
	IF @SysInsuranceID IS NULL
	RAISERROR (50103, 16, 1)
	
	
	DECLARE @SysTableId INT
		SET  @SysTableId = (SELECT TOP 1 [SysTablesID] FROM dbo.tblSystemTables WHERE TablesID = 'MISSING.INFO')
	
	IF NOT EXISTS (
		SELECT 1
		FROM dbo.tblSystemTableDetails
		WHERE
			SysTablesID = @SysTableId
			AND Code = @RequiredField
	)
	RAISERROR (50103, 16, 1)
	
	IF EXISTS (
	SELECT 1
	FROM tblInsurance_MissingInformation
	WHERE
		SysInsuranceId = @SysInsuranceID
		AND MissingInformation = @RequiredField
	)
	RAISERROR(50106, 16, 1)
	
	INSERT INTO tblInsurance_MissingInformation(
		SysInsuranceId, 
		MissingInformation
	)
	VALUES(
		@SysInsuranceID, 
		@RequiredField
	)
	
	 IF @TranCounter = 0
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




IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_DELETE_SystemTableById') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.usp_SBC_DELETE_SystemTableById

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_DELETE_SystemTableById
 * 
 * Purpose:       Removes the system table items by Table's ID
 * 
 * Rules:
 * 
 * Parameters:   TableID		VARCHAR(60)  - Table's type
 *				 UserID			VARCHAR(255) - The user id who performs this operation.
 * Returns:      None
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
CREATE PROC dbo.usp_SBC_DELETE_SystemTableById
   @TableID    VARCHAR(60),
   @UserID     VARCHAR(255)
AS


DELETE FROM dbo.tblSystemTableDetails 
	WHERE SysTablesID IN (
			SELECT SysTablesID FROM dbo.tblSystemTables 
				WHERE  TablesID = @TableID
			)

GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_SystemTableRecord') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.usp_SBC_CREATE_SystemTableRecord

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_CREATE_SystemTableRecord
 * 
 * Purpose:       Updates the system table item by Table's ID
 * 
 * Rules:         
 * 
 * Parameters:   TableID		 VARCHAR(60)  - Table's identifier
 *				 Code			 VARCHAR(24)  - System's table record according HCPC code definition
 *				 CodeDescription VARCHAR(60)  - Short description for this HCPC-Code
 *				 OptionalInfo	 VARCHAR(30)  - Optional information about this record
 *				 UserID			 VARCHAR(255) - The user id who performs this operation.
 * Returns:      None
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
CREATE PROC dbo.usp_SBC_CREATE_SystemTableRecord
   @TableID			VARCHAR(60),
   @Code			VARCHAR(24),
   @CodeDescription VARCHAR(60),
   @OptionalInfo	VARCHAR(30),
   @UserID			VARCHAR(255)
AS

DECLARE @SysTableID INT;

SET @SysTableID = (
	SELECT TOP 1 SysTablesID 
		FROM dbo.tblSystemTables 
		WHERE TablesID = @TableID
	);
	
IF @SysTableID IS NULL
BEGIN
	RAISERROR(50102, 16, 1)
	RETURN
END

IF EXISTS (
	SELECT 1
	FROM dbo.tblSystemTableDetails
	WHERE
		SysTablesID = @SysTableID
		AND Code = @Code
)
BEGIN
	RAISERROR(50104, 16, 1)
	RETURN
END

INSERT INTO tblSystemTableDetails(
		SysTablesID,
		Code,
		CodeDescription,
		OptionalInfo
	)
	VALUES(
		@SysTableID,
		@Code,
		@CodeDescription,
		@OptionalInfo
	)

GO


IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_PatientDetails') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_PatientDetails

GO


/**************************************************************************
 * Proc Name:     dbo.usp_SBC_SELECT_PatientDetails
 * 
 * Purpose:       Returns the patient information for SBC API.
 * 
 * Rules:
 * 
 * Parameters:   PatientID		VARCHAR(20)  - Patient identifier.
 *				 UserID			VARCHAR(255) - The user id who performs this operation.
 *				 DeptID			INT - Department associated with patient identified by PatientID.
 *			 	 ComputerName	VARCHAR(20) - Machine name where SBC API is running.
 * Returns:      Patient information.
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

CREATE PROC dbo.usp_SBC_SELECT_PatientDetails
	@PatientID  VARCHAR(20),
    @UserID     VARCHAR(255),
    @DeptID		INT,
    @ComputerName VARCHAR(20)
AS

DECLARE @SysPatientID INT

Set @SysPatientID = (SELECT tblPatient.SysPatId FROM dbo.tblPatient WHERE tblPatient.PatientID = @PatientID)

BEGIN TRY
	BEGIN TRANSACTION;
	
	-- tblPatient

	SELECT
		PatientID,
		@DeptID as DepartmentID,
		PatFullName,
		PatFirstName,
		PatLastName,
		PatMiddleInitial,
		Credentials,
		PatAddress,
		PatZipCode,
		PatCity,
		PatState,
		PatPhone,
		PatSSN,
		PatDOB,
		EmployerName,
		EmployerPhone,
		InjuryDate,
		IsEmploymentRelated,
		IsAutoRelated,
		IsOtherAccident,
		AccidentState,
		GETDATE() AS EntityTimeStamp
	FROM
		dbo.tblPatient
		LEFT JOIN dbo.tblPatient_Department
			ON tblPatient.SysPatId  = tblPatient_Department.SysPatId
	WHERE
		tblPatient.SysPatId = @SysPatientID


	--tblPatient_Comments

	SELECT
		tblPatient_Comments.SysPatCommentId,
		tblPatient.PatientID,
		tblPatient_Comments.Comments,
		CommentOrder
	FROM
		dbo.tblPatient_Comments
		JOIN dbo.tblPatient
			ON dbo.tblPatient.SysPatId  = tblPatient_Comments.SysPatId
		WHERE @SysPatientID = tblPatient_Comments.SysPatId
		AND tblPatient_Comments.IsGeneral = 1

	-- tblPatient_Department

	SELECT
		DepartmentID,
		tblPatient.PatientID,
		Comments
	FROM
		dbo.tblPatient_Department 
		LEFT JOIN dbo.tblPatient
			ON tblPatient.SysPatId  = tblPatient_Department.SysPatId
	WHERE
		tblPatient_Department.SysPatId = @SysPatientID 
		AND (tblPatient_Department.DepartmentID = @DeptID OR @DeptID IS NULL)

	-- tblPatient_Diagnosis

	SELECT
		tblPatient_Diagnosis.SysPatDiagnosisId,
		tblDiagnosisCode.DiagnosisCodeID,
		tblPatient_Diagnosis.DepartmentID,
		tblPatient.PatientID,
		tblDiagnosisCode.CommonDescription,
		OnsetDate,
		DiagnosisCodeOrder
	FROM
		dbo.tblPatient_Diagnosis
		LEFT JOIN dbo.tblDiagnosisCode
			ON tblPatient_Diagnosis.SysDiagnosisCodeID = tblDiagnosisCode.SysDiagnosisCodeID
		LEFT JOIN dbo.tblPatient
			ON tblPatient.SysPatId = tblPatient_Diagnosis.SysPatId
	WHERE
		tblPatient_Diagnosis.SysPatId = @SysPatientID
		AND (tblPatient_Diagnosis.DepartmentID = @DeptID OR @DeptID IS NULL)


	-- tblPatient_Insurance

	SELECT
		DepartmentID,
		tblPatient.PatientID,
		tblInsurance.InsuranceID,
		tblPatient_Insurance.InsuranceName,
		PolicyNumber AS PolicyId,
		GroupNumber,
		tblPatient_Insurance.InsuredName,
		InsuredDOB,
		Relationship AS InsuredRelationCode,
		Coverage,
		Deductible,
		EffectiveFrom AS EffectiveFromDate,
		EffectiveTo AS EffectiveToDate,
		IsCopay,
		CopayAmount,
		AuthNumber,
		AuthFrom,
		AuthTo,
		AuthVisits,
		AuthAmount,
		RefNumber,
		PayorOrder,
		InsuredSex,
		InsuredAddress,
		InsuredCity,
		InsuredState,
		InsuredZip,
		InsuredPhone,
		InsuredEmployer,
		PayorContactName,
		PayorContactComments,
		InsuranceAddress,
		InsuranceCity,
		InsuranceState,
		InsuranceZip,
		SecondaryMedicareType,
		PCClaimNumber,
		PCClaimFrom,
		PCClaimTo,
		RefFrom,
		RefTo,
		RefVisits,
		RefAmount,
		'' AS UserID,
        '' AS ComputerName,
        GETDATE() AS UpdatePatientDate,
        GETDATE() AS EntityTimeStamp
	FROM
		dbo.tblPatient_Insurance
		LEFT JOIN dbo.tblInsurance
			ON tblInsurance.SysInsuranceId = tblPatient_Insurance.SysInsuranceId
		LEFT JOIN dbo.tblPatient
			ON tblPatient.SysPatId  = tblPatient_Insurance.SysPatId
	WHERE
		tblPatient_Insurance.SysPatId = @SysPatientID
		AND (DepartmentID = @DeptID OR @DeptID IS NULL)

	-- tblPatient_ReferralDoctor

	SELECT
		tblReferralDoctor.ReferralDoctorID,
		tblPatient.PatientID,
		tblReferralDoctor.ReferralDoctorName,
		Phone
	FROM
		dbo.tblPatient_ReferralDoctor
		LEFT JOIN dbo.tblReferralDoctor
			ON tblReferralDoctor.SysReferralDoctorID = tblPatient_ReferralDoctor.SysReferralDoctorID
		LEFT JOIN dbo.tblPatient
			ON tblPatient.SysPatId = tblPatient_ReferralDoctor.SysPatId
	WHERE
		tblPatient_ReferralDoctor.SysPatId = @SysPatientID
		AND tblPatient_ReferralDoctor.IOrder = 1

	
	IF @SysPatientID IS NOT NULL
	INSERT INTO tblHCAL (
		HCALID,
		ApplicationName,
		OperatorID,
		HCALDateTime,
		ComputerName,
		ThreadId,
		[Type],
		PatientID,
		DepartmentID,
		Duration,
		PrinterName,
		FormName,
		ItemId
	)	 
	VALUES (
		ISNULL((SELECT MAX(HCALID) + 1 FROM tblHCAL), 1),
		'SBCAPI',
		@UserID,
		GETDATE(),
		@ComputerName,
		NULL,
		1,
		@PatientID,
		@DeptID,
		NULL,
		NULL,
		NULL,
		@PatientId
	) 

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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_UPDATE_PatientInfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_UPDATE_PatientInfo

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_UPDATE_PatientInfo
 * 
 * Purpose:       Update patient information from SBC API.
 * 
 * Rules:         
 * 
 * Parameters:    UserID			VARCHAR(255)- The user id who performs this operation.
 *				  ComputerName		VARCHAR(20)	- Machine name where SBC API is running.
 *				  PatientID			VARCHAR(20)	- Patient identifier.
 *				  DepartmentID		INT			- Department associated with patient identified by PatientID.
 *				  FullName			VARCHAR(130)- Patient’s full name.
 *				  FirstName			VARCHAR(35)	- Patient’s first name.
 *				  LastName			VARCHAR(60)	- Patient’s last name.
 *				  MiddleInitial	    VARCHAR(25)	- Patient’s middle initial.
 *				  Credentials	    VARCHAR(25)	- Patient’s middle initial.
 *				  Address			VARCHAR(40)	- Patient’s address.
 *				  ZipCode			VARCHAR(10)	- Patient’s zip code.
 *				  City				VARCHAR(35)	- Patient’s city.
 *				  State				CHAR(2)		- Patient’s state.
 *				  Phone				VARCHAR(12)	- Patient’s phone number.
 *				  SSN				VARCHAR(11)	- Patient’s Social Security number.
 *				  Birthday			DATETIME	- Patient’s birthday. Timezone is undefined because RT does not consider timezones.
 *				  EmployerName		VARCHAR(40)	- Patient's employer name.
 *				  EmployerPhone		VARCHAR(12)	- Patient's employer phone number.
 *				  UpdatePatientDate DATETIME	- Date of update patient operation.
 *				  EntityTimeStamp	DATETIME	- The last date of patient entity modification.
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

CREATE PROC dbo.usp_SBC_UPDATE_PatientInfo
    @UserID VARCHAR(255),
    @ComputerName VARCHAR(20),
    @PatientID  VARCHAR(20),
    @DepartmentID INT,
    @FullName VARCHAR(130),
    @FirstName VARCHAR(35),
	@LastName VARCHAR(60),
	@MiddleInitial VARCHAR(25),
	@Credentials VARCHAR(25),
	@Address VARCHAR(40),
	@ZipCode VARCHAR(10),
	@City VARCHAR(35),
	@State CHAR(2),
	@Phone VARCHAR(12),
	@SSN VARCHAR(11),
	@Birthday DATETIME,
	@EmployerName VARCHAR(40),
	@EmployerPhone VARCHAR(12),
	@UpdatePatientDate DATETIME,
	@EntityTimeStamp	DATETIME
AS

DECLARE @SysPatientID INT

Set @SysPatientID = (SELECT SysPatId FROM dbo.tblPatient WHERE PatientID = @PatientID)

IF @SysPatientID IS NULL
BEGIN
	RAISERROR(50102, 16, 1)
	RETURN
END

BEGIN TRY
	DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;
	
	IF EXISTS (
		SELECT 1
		FROM dbo.tblPatient_Audit
		WHERE
			SysPatId = @SysPatientID
			AND ModifiedDate > ISNULL(@EntityTimeStamp, CONVERT(DATETIME, 0))
	)
	RAISERROR (50101, 16, 1)
	
	DECLARE @ChangedFields XML
	
	SET @ChangedFields = N'<root><r>' + 
	(SELECT TOP 1
		CASE WHEN PatFullName = @FullName
			THEN '' 
			ELSE 'Changed : [Patient Full Name]  FROM: [' + ISNULL(PatFullName, '') + ']  TO: [' + ISNULL(@FullName, '') + ']' 
		END + '</r><r>' +	
		CASE WHEN PatFirstName = @FirstName
			THEN '' 
			ELSE 'Changed : [Patient First Name]  FROM: [' + ISNULL(PatFirstName, '') + ']  TO: [' + ISNULL(@FirstName, '') + ']' 
		END + '</r><r>' +
		CASE WHEN PatLastName = @LastName
			THEN '' 
			ELSE 'Changed : [Patient Last Name]  FROM: [' + ISNULL(PatLastName, '') + ']  TO: [' + ISNULL(@LastName, '') + ']' 
		END + '</r><r>' +
		CASE WHEN Credentials = @Credentials
			THEN '' 
			ELSE 'Changed : [Patient Credentials]  FROM: [' + ISNULL(Credentials, '') + ']  TO: [' + ISNULL(@Credentials, '') + ']' 
		END + '</r><r>' +			
		CASE WHEN PatMiddleInitial = @MiddleInitial
			THEN '' 
			ELSE 'Changed : [Patient Middle Initial]  FROM: [' + ISNULL(PatMiddleInitial, '') + ']  TO: [' + ISNULL(@MiddleInitial, '') + ']' 
		END + '</r><r>' +		
		CASE WHEN PatAddress = @Address
			THEN ''
			ELSE 'Changed : [Patient Address]  FROM: [' + ISNULL(PatAddress, '') + ']  TO: [' + ISNULL(@Address, '') + ']' 
		END + '</r><r>' +
		CASE WHEN PatZipCode = @ZipCode
			THEN ''
			ELSE 'Changed : [Patient Zip Code]  FROM: [' + ISNULL(PatZipCode, '') + ']  TO: [' + ISNULL(@ZipCode, '') + ']' 
		END + '</r><r>' +
		CASE WHEN PatCity = @City
			THEN ''
			ELSE 'Changed : [Patient City]  FROM: [' + ISNULL(PatCity, '') + ']  TO: [' + ISNULL(@City, '') + ']' 
		END + '</r><r>' +
		CASE WHEN PatState = @State
			THEN ''
			ELSE 'Changed : [Patient State]  FROM: [' + ISNULL(PatState, '') + ']  TO: [' + ISNULL(@State, '') + ']' 
		END + '</r><r>' +
		CASE WHEN PatPhone = @Phone
			THEN ''
			ELSE 'Changed : [Patient Phone]  FROM: [' + ISNULL(PatPhone, '') + ']  TO: [' + ISNULL(@Phone, '') + ']' 
		END + '</r><r>' +
		CASE WHEN PatSSN = @SSN
			THEN ''
			ELSE 'Changed : [Patient SSN]  FROM: [' + ISNULL(PatSSN, '') + ']  TO: [' + ISNULL(@SSN, '') + ']' 
		END + '</r><r>' +
		CASE WHEN PatDOB = @Birthday
			THEN ''
			ELSE 'Changed : [Patient DOB]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), PatDOB), '') + ']  TO: [' + ISNULL(CONVERT(VARCHAR(30), @Birthday), '') + ']' 
		END + '</r><r>' +
		CASE WHEN EmployerName = @EmployerName
			THEN ''
			ELSE 'Changed : [Patient Employer Name]  FROM: [' + ISNULL(EmployerName, '') + ']  TO: [' + ISNULL(@EmployerName, '') + ']' 
		END + '</r><r>' +
		CASE WHEN EmployerPhone = @EmployerPhone
			THEN ''
			ELSE 'Changed : [Patient Employer Phone]  FROM: [' + ISNULL(EmployerPhone, '') + ']  TO: [' + ISNULL(@EmployerPhone, '') + ']' 
		END
	FROM dbo.tblPatient
	WHERE
		SysPatId = @SysPatientID) + '</r></root>'
	
	UPDATE dbo.tblPatient
	SET PatFullName = @FullName,
		PatFirstName = @FirstName,
		PatLastName = @LastName,
		PatMiddleInitial = @MiddleInitial,
		Credentials = @Credentials,
		PatAddress = @Address,
		PatZipCode = @ZipCode,
		PatCity = @City,
		PatState = @State,
		PatPhone = @Phone,
		PatSSN = @SSN,
		PatDOB = @Birthday,
		EmployerName = @EmployerName,
		EmployerPhone = @EmployerPhone
	WHERE SysPatId = @SysPatientID


	-- VARIABLES FOR AUDIT
	DECLARE @ApplicationName VARCHAR(20) = 'SBCAPI'
	DECLARE	@HCALIDS TABLE(HCALID INT)
	DECLARE @HCALID INT
	
	-- dbo.tblPatient_Audit
	INSERT INTO dbo.tblPatient_Audit (
		SysPatID,
		ModIFiedUser,
		ModIFiedDate
		)
	VALUES (
		@SysPatientID,
		@UserID,
		@UpdatePatientDate
	)
			
	SET @HCALID = (
		SELECT TOP 1
			HCALID
		FROM dbo.tblHCAL
		WHERE
			ApplicationName = @ApplicationName
			AND	OperatorID = @UserID
			AND HCALDateTime = @UpdatePatientDate
			AND PatientID = @PatientID
		)
	
	IF @HCALID IS NULL
	BEGIN

		-- dbo.tblHCAL
		INSERT INTO dbo.tblHCAL (
			HCALID,
			ApplicationName, 
			OperatorID, 
			HCALDateTime, 
			ComputerName, 
			ThreadId, 
			[Type], 
			PatientID, 
			DepartmentID, 
			Duration, 
			PrinterName, 
			FormName, 
			ItemId
		)
		OUTPUT INSERTED.HCALID INTO @HCALIDS
		VALUES (
			ISNULL((SELECT MAX(HCALID) + 1 FROM tblHCAL), 1),
			@ApplicationName, 
			@UserID,
			@UpdatePatientDate,
			@ComputerName, 
			NULL, 
			2, 
			@PatientID, 
			'N/A', 
			NULL, 
			NULL, 
			NULL, 
			@PatientId
		) 
		
		SET @HCALID = (SELECT TOP 1 HCALID FROM @HCALIDS)
		
	END
		
	-- dbo.tblHCALChFields
	INSERT INTO dbo.tblHCALChFields (
		HCALID, 
		ChangedFields 
		) 
	SELECT
		@HCALID,
		r.value('.','VARCHAR(MAX)')
	FROM @ChangedFields.nodes('//root/r') AS RECORDS(r)	
	WHERE r.value('.','VARCHAR(MAX)') <> ''
	

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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_DELETE_PatientInsurances') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_DELETE_PatientInsurances

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_DELETE_PatientInsurances
 * 
 * Purpose:       Deletes patient insurances information from SBC API.
 * 
 * Rules:         
 * 
 * Parameters:  UserID				VARCHAR(255)- The user id who performs this operation.
 *				ComputerName		VARCHAR(20) - Machine name where SBC API is running.
 *				PatientID			VARCHAR(20)	- Patient identifier.
 *				UpdatePatientDate	DATETIME	- Date of update patient operation.
 *				EntityTimeStamp		DATETIME	- The last date of patient entity modification.
 * 
 * Returns:       
 * 
 * Called By:	SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_DELETE_PatientInsurances
    @UserID				VARCHAR(255),
    @ComputerName		VARCHAR(20),
    @PatientID			VARCHAR(20),
	@UpdatePatientDate	DATETIME,
	@EntityTimeStamp	DATETIME
AS

DECLARE @SysPatientID INT
Set @SysPatientID = (SELECT SysPatId FROM dbo.tblPatient WHERE PatientID = @PatientID)

BEGIN TRY
	DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;
	
	IF @SysPatientID IS NULL
	RAISERROR(50102, 16, 1)
	
	DECLARE @ChangedFieldsList TABLE(ChangedFields XML)
	
	INSERT INTO @ChangedFieldsList (ChangedFields)
	SELECT N'<root><r>' +
		CASE WHEN I.InsuranceId IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - InsuranceId]  FROM: [' + ISNULL(I.InsuranceId, '') + ']  TO: []' 
		END + '</r><r>' + 
		CASE WHEN DepartmentID IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - DepartmentID]  FROM: [' + ISNULL(CONVERT(VARCHAR(12), DepartmentID), '') + ']  TO: []' 
		END + '</r><r>' + 
		CASE WHEN PayorOrder IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - PayorOrder]  FROM: [' + ISNULL(CONVERT(VARCHAR(6), PayorOrder), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN P.InsuranceName IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - Insurance Name]  FROM: [' + ISNULL(P.InsuranceName, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN PolicyNumber IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - Policy Number]  FROM: [' + ISNULL(PolicyNumber, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN GroupNumber IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Group Number]  FROM: [' + ISNULL(GroupNumber, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuredName IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Name]  FROM: [' + ISNULL(InsuredName, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuredDOB IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured DOB]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), InsuredDOB), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN Relationship IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Relationship]  FROM: [' + ISNULL(Relationship, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN Coverage IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Coverage]  FROM: [' + ISNULL(CONVERT(VARCHAR(12), Coverage), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN Deductible IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Deductible]  FROM: [' + ISNULL(CONVERT(VARCHAR(60), Deductible), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN EffectiveFrom IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Effective From]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), EffectiveFrom), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN EffectiveTo IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Effective To]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), EffectiveTo), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN IsCopay IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - IsCopay]  FROM: [' + ISNULL(CONVERT(VARCHAR(1), IsCopay), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN AuthNumber IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth Number]  FROM: [' + ISNULL(AuthNumber, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN AuthFrom IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth From]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), AuthFrom), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN AuthTo IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth To]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), AuthTo), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN AuthVisits IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth Visits]  FROM: [' + ISNULL(CONVERT(VARCHAR(12), AuthVisits), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN RefNumber IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Ref Number]  FROM: [' + ISNULL(RefNumber, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN CopayAmount IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Copay Amount]  FROM: [' + ISNULL(CONVERT(VARCHAR(38), CopayAmount), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN AuthAmount IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth Amount]  FROM: [' + ISNULL(CONVERT(VARCHAR(21), AuthAmount), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuredSex IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Sex]  FROM: [' + ISNULL(InsuredSex, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuredAddress IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Address]  FROM: [' + ISNULL(InsuredAddress, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuredCity IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured City]  FROM: [' + ISNULL(InsuredCity, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuredState IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured State]  FROM: [' + ISNULL(InsuredState, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuredZip IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Zip]  FROM: [' + ISNULL(InsuredZip, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuredPhone IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Phone]  FROM: [' + ISNULL(InsuredPhone, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuredEmployer IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Employer]  FROM: [' + ISNULL(InsuredEmployer, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN PayorContactName IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Payor Contact Name]  FROM: [' + ISNULL(PayorContactName, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN PayorContactComments IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Payor Contact Comments]  FROM: [' + ISNULL(PayorContactComments, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuranceAddress IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insurance Address]  FROM: [' + ISNULL(InsuranceAddress, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuranceCity IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insurance City]  FROM: [' + ISNULL(InsuranceCity, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN InsuranceState IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insurance State]  FROM: [' + ISNULL(InsuranceState, '') + ']  TO: []' 
		END	+ '</r><r>' +
		CASE WHEN InsuranceZip IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insurance Zip]  FROM: [' + ISNULL(InsuranceZip, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN SecondaryMedicareType IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Secondary Medicare Type]  FROM: [' + ISNULL(SecondaryMedicareType, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN PCClaimNumber IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - PCClaim Number]  FROM: [' + ISNULL(PCClaimNumber, '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN PCClaimFrom IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - PCClaim From]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), PCClaimFrom), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN PCClaimTo IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - PCClaim To]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), PCClaimTo), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN RefFrom IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Ref From]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), RefFrom), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN RefTo IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Ref To]  FROM: [' + ISNULL(CONVERT(VARCHAR(30), RefTo), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN RefVisits IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Ref Visits]  FROM: [' + ISNULL(CONVERT(VARCHAR(12), RefVisits), '') + ']  TO: []' 
		END + '</r><r>' +
		CASE WHEN RefAmount IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - RefAmount]  FROM: [' + ISNULL(CONVERT(VARCHAR(21), RefAmount), '') + ']  TO: []' 
		END + '</r></root>'
	FROM dbo.tblPatient_Insurance AS P
	INNER JOIN dbo.tblInsurance AS I
		ON I.SysInsuranceId = P.SysInsuranceId
	WHERE
		SysPatId = @SysPatientID
			
	DELETE FROM dbo.tblPatient_Insurance
	WHERE
		SysPatId = @SysPatientID
			
	-- VARIABLES FOR AUDIT
	DECLARE @ApplicationName VARCHAR(20) = 'SBCAPI'
	DECLARE	@HCALIDS TABLE(HCALID INT)
	DECLARE @HCALID INT

	SET @HCALID = (
		SELECT TOP 1
			HCALID
		FROM dbo.tblHCAL
		WHERE
			ApplicationName = @ApplicationName
			AND	OperatorID = @UserID
			AND HCALDateTime = @UpdatePatientDate
			AND PatientID = @PatientID
		)
	
	IF @HCALID IS NULL
	BEGIN

		-- dbo.tblHCAL
		INSERT INTO dbo.tblHCAL (
			HCALID,
			ApplicationName, 
			OperatorID, 
			HCALDateTime, 
			ComputerName, 
			ThreadId, 
			[Type], 
			PatientID, 
			DepartmentID, 
			Duration, 
			PrinterName, 
			FormName, 
			ItemId
		)
		OUTPUT INSERTED.HCALID INTO @HCALIDS
		VALUES (
			ISNULL((SELECT MAX(HCALID) + 1 FROM tblHCAL), 1),
			@ApplicationName, 
			@UserID,
			@UpdatePatientDate,
			@ComputerName, 
			NULL, 
			2, 
			@PatientID, 
			'N/A',
			NULL, 
			NULL, 
			NULL, 
			@PatientId
		) 
		
		SET @HCALID = (SELECT TOP 1 HCALID FROM @HCALIDS)
	
	END					

	-- dbo.tblHCALChFields
	INSERT INTO dbo.tblHCALChFields (
		HCALID, 
		ChangedFields 
		)
	SELECT
		@HCALID,
		r.value('.','VARCHAR(MAX)')
	FROM
		@ChangedFieldsList
		CROSS APPLY ChangedFields.nodes('//root/r') AS RECORDS(r)
	WHERE r.value('.','VARCHAR(MAX)') <> ''
	
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_PatientInsurance') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_CREATE_PatientInsurance

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_CREATE_PatientInsurance
 * 
 * Purpose:       Creates patient insurance information in SBC API.
 * 
 * Rules:         
 * 
 * Parameters:  UserID				VARCHAR(255)- The user id who performs this operation.
 *				ComputerName		VARCHAR(20) - Machine name where SBC API is running.
 *				PatientID			VARCHAR(20)	- Patient identifier.
 *				InsuranceID			VARCHAR(10) - Insurance carrier identifier. 
 *				DepartmentID		INT			- Department associated with patient identified by PatientID.
 *				InsuranceName		VARCHAR(60) - Insurance carrier name.
 *				PolicyId			VARCHAR(80) - Policy identifier.
 *				GroupNumber			VARCHAR(50) - Group number.
 *				InsuredName			VARCHAR(130)- Insured name in the same format as patient full name (lastname_credentials,firstname middleinitial).
 *				InsuredDOB			DATETIME	- Insured date of birth. Timezone is undefined because RT does not consider timezones.
 *				InsuredRelationCode VARCHAR(24) - Insured relation code in the system table RELATION.
 *				Coverage			INT			- A percentage coverage that the insurance carrier is covering (stored as integer, 
 *													e.g. if the coverage was 15%, 15 would be stored in the coverage field).
 *				Deductible			FLOAT		- Amount of expenses that must be paid out of pocket before an insurer will pay any expenses.
 *				EffectiveFromDate	DATETIME	- Date at which the insurance is effective. Timezone is undefined because RT does not consider timezones.
 *				EffectiveToDate		DATETIME	- Date up to which the insurance is effective. Timezone is undefined because RT does not consider timezones.
 *				IsCopay				BIT			- Indicates whether insurance has a copayment.
 *				CopayAmount			FLOAT		- Copay amount.
 *				AuthNumber			VARCHAR(50) - Insurance authentication number.
 *				AuthFrom			DATETIME	- Start date of insurance authentication number. Timezone is undefined because RT does not consider timezones.
 *				AuthTo				DATETIME	- End date of insurance authentication number. Timezone is undefined because RT does not consider timezones.
 *				AuthVisits			INT			- Number of authenticate visits.
 *				AuthAmount			MONEY		- Auth amount.
 *				RefNumber			VARCHAR(50) - Reference number.
 *				PayorOrder			SMALLINT	- Payor order.
 *				UpdatePatientDate	DATETIME	- Date of update patient operation.
 *				EntityTimeStamp		DATETIME	- The last date of patient entity modification.
 *				InsuredSex			CHAR(1)		- Insured sex.
 *				InsuredAddress		VARCHAR(55) - Insured address.
 *				InsuredCity			VARCHAR(35) - Insured city.
 *				InsuredState		CHAR(2)		- Insured state.
 *				InsuredZip			VARCHAR(10) - Insured zip.
 *				InsuredPhone		VARCHAR(12) - Insured phone.
 *				InsuredEmployer		VARCHAR(50) - Insured employer.
 *				PayorContactName	VARCHAR(50) - Payor contact name.
 *				PayorContactComments VARCHAR(100) - Payor contact comments.
 *				InsuranceAddress	VARCHAR(40) - Insurance address.
 *				InsuranceCity		VARCHAR(35) - Insurance city.
 *				InsuranceState		CHAR(2)		- Insurance state.
 *				InsuranceZip		VARCHAR(10) - Insurance zip.
 *				SecondaryMedicareType VARCHAR(24) - Secondary medicare type.
 *				PCClaimNumber		VARCHAR(50) - PC claim number.
 *				PCClaimFrom			DATETIME	- PC claim from.
 *				PCClaimTo			DATETIME	- PC claim to.
 *				RefFrom				DATETIME	- Ref from.
 *				RefTo				DATETIME	- Ref to.
 *				RefVisits			INT			- Ref visits.
 *				RefAmount			MONEY		- Ref amount.
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

CREATE PROC dbo.usp_SBC_CREATE_PatientInsurance
    @UserID				VARCHAR(255),
    @ComputerName		VARCHAR(20),
    @PatientID			VARCHAR(20),
	@InsuranceID		VARCHAR(10),
	@DepartmentID		INT,
	@InsuranceName		VARCHAR(60),
	@PolicyId			VARCHAR(80),
	@GroupNumber		VARCHAR(50),
	@InsuredName		VARCHAR(130),
	@InsuredDOB			DATETIME,
	@InsuredRelationCode VARCHAR(24),
	@Coverage			INT,
	@Deductible			FLOAT,
	@EffectiveFromDate	DATETIME,
	@EffectiveToDate	DATETIME,
	@IsCopay			BIT,
	@CopayAmount		FLOAT,
	@AuthNumber			VARCHAR(50),
	@AuthFrom			DATETIME,
	@AuthTo				DATETIME,
	@AuthVisits			INT,
	@AuthAmount			MONEY,
	@RefNumber			VARCHAR(50),
	@PayorOrder			SMALLINT,
	@UpdatePatientDate	DATETIME,
	@EntityTimeStamp	DATETIME,
	@InsuredSex			CHAR(1),
	@InsuredAddress		VARCHAR(55),
	@InsuredCity		VARCHAR(35),
	@InsuredState		CHAR(2),
	@InsuredZip			VARCHAR(10),
	@InsuredPhone		VARCHAR(12),
	@InsuredEmployer	VARCHAR(50),
	@PayorContactName	VARCHAR(50),
	@PayorContactComments VARCHAR(100),
	@InsuranceAddress	VARCHAR(40),
	@InsuranceCity		VARCHAR(35),
	@InsuranceState		CHAR(2),
	@InsuranceZip		VARCHAR(10),
	@SecondaryMedicareType VARCHAR(24),
	@PCClaimNumber		VARCHAR(50),
	@PCClaimFrom		DATETIME,
	@PCClaimTo			DATETIME,
	@RefFrom			DATETIME,
	@RefTo				DATETIME,
	@RefVisits			INT,
	@RefAmount			MONEY
AS

DECLARE @SysPatientID INT,
		@SysInsuranceID INT

Set @SysPatientID = (SELECT SysPatId FROM dbo.tblPatient WHERE PatientID = @PatientID)
Set @SysInsuranceID = (SELECT SysInsuranceId FROM dbo.tblInsurance WHERE InsuranceID = @InsuranceID)

BEGIN TRY
	DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;
	
	IF @SysPatientID IS NULL
	RAISERROR(50102, 16, 1)
	
	IF @SysInsuranceID IS NULL
	OR NOT EXISTS (
		SELECT 1
		FROM dbo.tblDepartment
		WHERE DepartmentID = @DepartmentID
	)
	OR NOT EXISTS (
		SELECT 1
		FROM
			dbo.tblSystemTables AS ST
			INNER JOIN dbo.tblSystemTableDetails STD
				ON STD.SysTablesID = ST.SysTablesID
		WHERE
			ST.TablesID = 'STATES'
			AND STD.Code = COALESCE(@InsuranceState, STD.Code)
		)
	OR NOT EXISTS (
		SELECT 1
		FROM
			dbo.tblSystemTables AS ST
			INNER JOIN dbo.tblSystemTableDetails STD
				ON STD.SysTablesID = ST.SysTablesID
		WHERE
			ST.TablesID = 'STATES'
			AND STD.Code = COALESCE(@InsuredState, STD.Code)
		)
	OR NOT EXISTS (
		SELECT 1
		FROM
			dbo.tblSystemTables AS ST
			INNER JOIN dbo.tblSystemTableDetails STD
				ON STD.SysTablesID = ST.SysTablesID
		WHERE
			ST.TablesID = 'MEDICARE.SECONDARY.TYPE'
			AND STD.Code = COALESCE(@SecondaryMedicareType, STD.Code)
		)
	OR NOT EXISTS (
		SELECT 1
		FROM
			dbo.tblSystemTables AS ST
			INNER JOIN dbo.tblSystemTableDetails STD
				ON STD.SysTablesID = ST.SysTablesID
		WHERE
			ST.TablesID = 'RELATION'
			AND STD.Code = COALESCE(@InsuredRelationCode, STD.Code)
	)
	RAISERROR(50103, 16, 1)

	IF EXISTS (
		SELECT 1
		FROM dbo.tblPatient_Insurance
		WHERE
			SysPatId = @SysPatientID
			AND DepartmentID = @DepartmentID
			AND PayorOrder = @PayorOrder
	)
	RAISERROR(50106, 16, 1)

	DECLARE @ChangedFields XML = NULL
	
	SET @ChangedFields = N'<root><r>' + 
		CASE WHEN @InsuranceID IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - InsuranceId]  FROM: []  TO: [' + ISNULL(@InsuranceID, '') + ']' 
		END + '</r><r>' + 
		CASE WHEN @DepartmentID IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - DepartmentID]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(12), @DepartmentID), '') + ']' 
		END + '</r><r>' + 
		CASE WHEN @PayorOrder IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - PayorOrder]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(6), @PayorOrder), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuranceName IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - Insurance Name]  FROM: []  TO: [' + ISNULL(@InsuranceName, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @PolicyId IS NULL
			THEN '' 
			ELSE 'Changed : [Insurances - Policy Number]  FROM: []  TO: [' + ISNULL(@PolicyId, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @GroupNumber IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Group Number]  FROM: []  TO: [' + ISNULL(@GroupNumber, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredName IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Name]  FROM: []  TO: [' + ISNULL(@InsuredName, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredDOB IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured DOB]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(30), @InsuredDOB), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredRelationCode IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Relationship]  FROM: []  TO: [' + ISNULL(@InsuredRelationCode, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @Coverage IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Coverage]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(12), @Coverage), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @Deductible IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Deductible]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(60), @Deductible), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @EffectiveFromDate IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Effective From]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(30), @EffectiveFromDate), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @EffectiveToDate IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Effective To]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(30), @EffectiveToDate), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @IsCopay IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - IsCopay]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(1), @IsCopay), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @AuthNumber IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth Number]  FROM: []  TO: [' + ISNULL(@AuthNumber, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @AuthFrom IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth From]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(30), @AuthFrom), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @AuthTo IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth To]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(30), @AuthTo), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @AuthVisits IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth Visits]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(12), @AuthVisits), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @RefNumber IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Ref Number]  FROM: []  TO: [' + ISNULL(@RefNumber, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @CopayAmount IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Copay Amount]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(38), @CopayAmount), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @AuthAmount IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Auth Amount]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(21), @AuthAmount), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredSex IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Sex]  FROM: []  TO: [' + ISNULL(@InsuredSex, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredAddress IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Address]  FROM: []  TO: [' + ISNULL(@InsuredAddress, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredCity IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured City]  FROM: []  TO: [' + ISNULL(@InsuredCity, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredState IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured State]  FROM: []  TO: [' + ISNULL(@InsuredState, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredZip IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Zip]  FROM: []  TO: [' + ISNULL(@InsuredZip, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredPhone IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Phone]  FROM: []  TO: [' + ISNULL(@InsuredPhone, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuredEmployer IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insured Employer]  FROM: []  TO: [' + ISNULL(@InsuredEmployer, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @PayorContactName IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Payor Contact Name]  FROM: []  TO: [' + ISNULL(@PayorContactName, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @PayorContactComments IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Payor Contact Comments]  FROM: []  TO: [' + ISNULL(@PayorContactComments, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuranceAddress IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insurance Address]  FROM: []  TO: [' + ISNULL(@InsuranceAddress, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuranceCity IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insurance City]  FROM: []  TO: [' + ISNULL(@InsuranceCity, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @InsuranceState IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insurance State]  FROM: []  TO: [' + ISNULL(@InsuranceState, '') + ']' 
		END	+ '</r><r>' +
		CASE WHEN @InsuranceZip IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Insurance Zip]  FROM: []  TO: [' + ISNULL(@InsuranceZip, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @SecondaryMedicareType IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Secondary Medicare Type]  FROM: []  TO: [' + ISNULL(@SecondaryMedicareType, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @PCClaimNumber IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - PCClaim Number]  FROM: []  TO: [' + ISNULL(@PCClaimNumber, '') + ']' 
		END + '</r><r>' +
		CASE WHEN @PCClaimFrom IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - PCClaim From]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(30), @PCClaimFrom), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @PCClaimTo IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - PCClaim To]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(30), @PCClaimTo), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @RefFrom IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Ref From]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(30), @RefFrom), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @RefTo IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Ref To]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(30), @RefTo), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @RefVisits IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - Ref Visits]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(12), @RefVisits), '') + ']' 
		END + '</r><r>' +
		CASE WHEN @RefAmount IS NULL
			THEN ''
			ELSE 'Changed : [Insurances - RefAmount]  FROM: []  TO: [' + ISNULL(CONVERT(VARCHAR(21), @RefAmount), '') + ']' 
		END + '</r></root>'

		
		INSERT INTO dbo.tblPatient_Insurance (
			SysPatId,
			DepartmentID,
			SysInsuranceId,
			PolicyNumber,
			GroupNumber,
			InsuranceName,
			InsuredName,
			InsuredDOB,
			Relationship,
			Coverage,
			Deductible,
			EffectiveFrom,
			EffectiveTo,
			IsCopay,
			CopayAmount,
			AuthNumber,
			AuthFrom,
			AuthTo,
			AuthVisits,
			AuthAmount,
			RefNumber,
			PayorOrder,
			InsuredSex,
			InsuredAddress,
			InsuredCity,
			InsuredState,
			InsuredZip,
			InsuredPhone,
			InsuredEmployer,
			PayorContactName,
			PayorContactComments,
			InsuranceAddress,
			InsuranceCity,
			InsuranceState,
			InsuranceZip,
			SecondaryMedicareType,
			PCClaimNumber,
			PCClaimFrom,
			PCClaimTo,
			RefFrom,
			RefTo,
			RefVisits,
			RefAmount
		)
		VALUES(
			@SysPatientID,
			@DepartmentID,
			@SysInsuranceId,
			@PolicyId,
			@GroupNumber,
			@InsuranceName,
			@InsuredName,
			@InsuredDOB,
			@InsuredRelationCode,
			@Coverage,
			@Deductible,
			@EffectiveFromDate,
			@EffectiveToDate,
			@IsCopay,
			@CopayAmount,
			@AuthNumber,
			@AuthFrom,
			@AuthTo,
			@AuthVisits,
			@AuthAmount,
			@RefNumber,
			@PayorOrder,
			@InsuredSex,
			@InsuredAddress,
			@InsuredCity,
			@InsuredState,
			@InsuredZip,
			@InsuredPhone,
			@InsuredEmployer,
			@PayorContactName,
			@PayorContactComments,
			@InsuranceAddress,
			@InsuranceCity,
			@InsuranceState,
			@InsuranceZip,
			@SecondaryMedicareType,
			@PCClaimNumber,
			@PCClaimFrom,
			@PCClaimTo,
			@RefFrom,
			@RefTo,
			@RefVisits,
			@RefAmount
		)
	
	IF @ChangedFields IS NOT NULL
	BEGIN
		
		-- VARIABLES FOR AUDIT
		DECLARE @ApplicationName VARCHAR(20) = 'SBCAPI'
		DECLARE	@HCALIDS TABLE(HCALID INT)
		DECLARE @HCALID INT

		SET @HCALID = (
			SELECT TOP 1
				HCALID
			FROM dbo.tblHCAL
			WHERE
				ApplicationName = @ApplicationName
				AND	OperatorID = @UserID
				AND HCALDateTime = @UpdatePatientDate
				AND PatientID = @PatientID
			)
		
		IF @HCALID IS NULL
		BEGIN

			-- dbo.tblHCAL
			INSERT INTO dbo.tblHCAL (
				HCALID,
				ApplicationName, 
				OperatorID, 
				HCALDateTime, 
				ComputerName, 
				ThreadId, 
				[Type], 
				PatientID, 
				DepartmentID, 
				Duration, 
				PrinterName, 
				FormName, 
				ItemId
			)
			OUTPUT INSERTED.HCALID INTO @HCALIDS
			VALUES (
				ISNULL((SELECT MAX(HCALID) + 1 FROM tblHCAL), 1),
				@ApplicationName, 
				@UserID,
				@UpdatePatientDate,
				@ComputerName, 
				NULL, 
				2, 
				@PatientID, 
				'N/A', 
				NULL, 
				NULL, 
				NULL, 
				@PatientId
			) 
			
			SET @HCALID = (SELECT TOP 1 HCALID FROM @HCALIDS)
		
		END					
			
		-- dbo.tblHCALChFields
		INSERT INTO dbo.tblHCALChFields (
			HCALID, 
			ChangedFields 
			) 
		SELECT
			@HCALID,
			r.value('.','VARCHAR(MAX)')
		FROM @ChangedFields.nodes('//root/r') AS RECORDS(r)	
		WHERE r.value('.','VARCHAR(MAX)') <> ''
	END

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


IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_UPDATE_PatientDepartment') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_UPDATE_PatientDepartment

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_UPDATE_PatientDepartment
 * 
 * Purpose:       Update patient department information from SBC API.
 * 
 * Rules:         
 * 
 * Parameters:    UserID			VARCHAR(255)- The user id who performs this operation.
 *				  ComputerName		VARCHAR(20)	- Machine name where SBC API is running.
 *				  PatientID			VARCHAR(20)	- Patient identifier.
 *				  DepartmentID		INT			- Department associated with patient identified by PatientID.
 *				  Comments			VARCHAR(MAX)- Patient’s comments for the particular department.
 *				  UpdatePatientDate DATETIME    - Date of update patient operation.
 *				  EntityTimeStamp	DATETIME	- The last date of patient entity modification.
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

CREATE PROC dbo.usp_SBC_UPDATE_PatientDepartment
    @UserID		VARCHAR(255),
    @ComputerName VARCHAR(20),
    @PatientID	VARCHAR(20),
	@DepartmentID INT,
	@Comments VARCHAR(MAX),
	@UpdatePatientDate DATETIME,
	@EntityTimeStamp	DATETIME
AS

DECLARE @SysPatientID INT

Set @SysPatientID = (SELECT SysPatId FROM dbo.tblPatient WHERE PatientID = @PatientID)

IF @SysPatientID IS NULL
BEGIN
	RAISERROR(50102, 16, 1)
	RETURN
END

BEGIN TRY
	DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;
	
	DECLARE @ChangedFields XML
        
	IF EXISTS (
		SELECT 1
		FROM dbo.tblPatient_Department
		WHERE
			SysPatId = @SysPatientID
			AND DepartmentID = @DepartmentID
		)
	-- Update
	BEGIN
		
		SET @ChangedFields = N'<root><r>' + 
		(SELECT TOP 1
			CASE WHEN Comments = @Comments
				THEN '' 
				ELSE 'Changed : [Departments - Comments]  FROM: [' + ISNULL(Comments, '') + ']  TO: [' + ISNULL(@Comments, '') + ']' 
			END
		FROM dbo.tblPatient_Department
		WHERE
			SysPatId = @SysPatientID
			AND DepartmentID = @DepartmentID) + '</r></root>'
		
		UPDATE dbo.tblPatient_Department
		SET Comments = @Comments
		WHERE
			SysPatId = @SysPatientID
			AND DepartmentID = @DepartmentID
			
	END
	ELSE
	-- Insert
	BEGIN
	
		IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblDepartment
			WHERE DepartmentID = @DepartmentID
		)
		RAISERROR(50103, 16, 1)
		
		SET @ChangedFields = N'<root><r>' + 
		(SELECT TOP 1
			CASE WHEN @Comments IS NULL
				THEN '' 
				ELSE 'Changed : [Departments - Comments]  FROM: []  TO: [' + ISNULL(@Comments, '') + ']'
			END
		) + '</r></root>'
		
		INSERT dbo.tblPatient_Department (
			SysPatID,
			DepartmentID,
			Comments
		)
		VALUES (
			@SysPatientID,
			@DepartmentID,
			@Comments
		)
			
	END

	-- VARIABLES FOR AUDIT
	DECLARE @ApplicationName VARCHAR(20) = 'SBCAPI'
	DECLARE	@HCALIDS TABLE(HCALID INT)
	DECLARE @HCALID INT
			
	SET @HCALID = (
		SELECT TOP 1
			HCALID
		FROM dbo.tblHCAL
		WHERE
			ApplicationName = @ApplicationName
			AND	OperatorID = @UserID
			AND HCALDateTime = @UpdatePatientDate
			AND PatientID = @PatientID
		)
	
	IF @HCALID IS NULL
	BEGIN

		-- dbo.tblHCAL
		INSERT INTO dbo.tblHCAL (
			HCALID,
			ApplicationName, 
			OperatorID, 
			HCALDateTime, 
			ComputerName, 
			ThreadId, 
			[Type], 
			PatientID, 
			DepartmentID, 
			Duration, 
			PrinterName, 
			FormName, 
			ItemId
		)
		OUTPUT INSERTED.HCALID INTO @HCALIDS
		VALUES (
			ISNULL((SELECT MAX(HCALID) + 1 FROM tblHCAL), 1),
			@ApplicationName, 
			@UserID,
			@UpdatePatientDate,
			@ComputerName, 
			NULL, 
			2,
			@PatientID, 
			'N/A', 
			NULL, 
			NULL, 
			NULL, 
			@PatientId
		) 
		
		SET @HCALID = (SELECT TOP 1 HCALID FROM @HCALIDS)
	
	END
	
	-- dbo.tblHCALChFields
	INSERT INTO dbo.tblHCALChFields (
		HCALID, 
		ChangedFields 
		) 
	SELECT
		@HCALID,
		r.value('.','VARCHAR(MAX)')
	FROM @ChangedFields.nodes('//root/r') AS RECORDS(r)	
	WHERE r.value('.','VARCHAR(MAX)') <> ''


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


IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_WorkfilesData') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_WorkfilesData

GO


/**************************************************************************
 * Proc Name:    dbo.usp_SBC_SELECT_WorkfilesData
 * 
 * Purpose:      Returns the list of workfiles for SBC API.
 * 
 * Rules:         
 * 
 * Parameters:   fromDate		DATETIME - Start date for searching period (inclusive). Timezone is undefined because RT does not consider timezones.
 *				 toDate			DATETIME - Last date for searching period (inclusive). Timezone is undefined because RT does not consider timezones.
 *				 IsActive		BIT - Flag that indicates active workfiles.
 *				 UserID			VARCHAR(255)- The user id who performs this operation.
 *			 	 ComputerName	VARCHAR(20) - Machine name where SBC API is running.
 * Returns:      List of workfiles.
 * 
 * Called By:	 SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_SELECT_WorkfilesData
	@fromDate	DATETIME = NULL,
	@toDate		DATETIME = NULL,
	@IsActive	BIT = NULL,
    @UserID     VARCHAR(255),	
    @ComputerName VARCHAR(20)
AS

BEGIN TRY
	BEGIN TRANSACTION;
	
	DECLARE @CollectionsList TABLE (
		CollectionClaimInfoID BIGINT IDENTITY(1, 1),
		CollectionID INT,
		SysCollectionID INT,
		ClaimID VARCHAR(15),
		SysPatId INT,
		SysLocationID INT,
		SysClaimID INT,
		SysClaimIDOrig INT,
		IsActive TINYINT,
		IsModified BIT
		)
	
	INSERT INTO @CollectionsList
	SELECT
		COL.CollectionID,
		COL.SysCollectionId,
		C.ClaimID,
		C.SysPatId,
		C.SysLocationID,
		C.SysClaimID,
		C.SysClaimIDOrig,
		CASE WHEN A.MaxClaimBalance > 0
			THEN 1
			ELSE 0
		END AS IsActive,
		CASE WHEN CS.SysClaimId IS NULL
			THEN 0
			ELSE 1
		END AS IsModified
	FROM
		dbo.tblCollections AS COL
		LEFT JOIN (
			SELECT
				CL.ClaimID,
				CL.SysPatId,
				CL.SysLocationID,
				CC.SysCollectionID,
				CL.SysClaimID,
				OCL.SysClaimID AS SysClaimIDOrig
			FROM
				dbo.tblClaim AS CL
				INNER JOIN dbo.tblCollections_Claim AS CC
					ON CC.SysClaimID = CL.SysClaimID
				-- Original claims
				INNER JOIN dbo.tblClaim AS OCL 
					ON OCL.ClaimID = LEFT(CL.ClaimID, CHARINDEX('_', CL.ClaimID) - 1)
					AND CHARINDEX('_', CL.ClaimID) > 0
			UNION
			SELECT
				CL.ClaimID,
				CL.SysPatId,
				CL.SysLocationID,
				CC.SysCollectionID,
				CL.SysClaimID,
				CL.SysClaimID AS SysClaimIDOrig
			FROM
				dbo.tblClaim AS CL
				INNER JOIN dbo.tblCollections_Claim AS CC
					ON CC.SysClaimID = CL.SysClaimID
			WHERE
				CHARINDEX('_', CL.ClaimID) = 0
		) AS C
			ON C.SysCollectionID = COL.SysCollectionId
		LEFT JOIN (
			SELECT
				SysClaimID,
				MAX(ISNULL(ClaimBalance, 0)) AS MaxClaimBalance
			FROM dbo.tblAccountC
			GROUP BY SysClaimID
		) AS A
			ON A.SysClaimID = C.SysClaimIDOrig
		LEFT JOIN (
			SELECT DISTINCT
				CS.SysClaimId
			FROM
				dbo.tblCollects AS CS
				INNER JOIN dbo.tblCollects_Audit AS CSA
					ON CSA.SysCollectSID = CS.SysCollectSID
					AND CSA.ModifiedDate BETWEEN @fromDate AND @toDate
		) AS CS
			ON CS.SysClaimId = C.SysClaimID
		LEFT JOIN (
			SELECT DISTINCT
				SysCollectionId
			FROM dbo.tblCollections_Audit
			WHERE ModifiedDate BETWEEN @fromDate AND @toDate
		) AS CA
			ON CA.SysCollectionId = C.SysCollectionId
	WHERE
		(A.MaxClaimBalance > 0 OR ISNULL(@IsActive, 0) = 0)
		AND( 
			COALESCE(@fromDate, @toDate) IS NULL
			OR CS.SysClaimId IS NOT NULL
			OR CA.SysCollectionId IS NOT NULL
		)
			
	
	-- CollectionInfo
	SELECT DISTINCT
		CollectionID,
		MAX(IsActive) AS IsActive
	FROM @CollectionsList
	GROUP BY CollectionID
		
	-- CollectionClaimInfo
	SELECT
		COL.CollectionClaimInfoID,
		COL.CollectionID,
		COL.ClaimID,
		P.PatientId,
		P.PatFullName AS PatientName,
		CASE WHEN ISNULL(AI.InsuranceId, '') = ''
			THEN AI.InsuranceType
			ELSE AI.InsuranceId
		END	AS InsuranceId,
		CASE WHEN ISNULL(AI.InsuranceId, '') = ''
			THEN
				CASE
					WHEN AI.InsuranceType = 'P'
						THEN 'Patient Responsibility'
					WHEN AI.InsuranceType = 'W'
						THEN 'Worker’s Compensation'
					ELSE NULL
				END
			ELSE I.InsuranceName
		END AS InsuranceName,
		P.AccountType,
		L.LocationID,
		A.ClaimBalance AS Balance,
		CASE WHEN ISNULL(A.ClaimBalance, 0) > 0
			THEN 1
			ELSE 0
		END	AS IsActive
	FROM
		@CollectionsList AS COL
		LEFT JOIN dbo.tblPatient AS P
			ON P.SysPatId = COL.SysPatId
		LEFT JOIN dbo.tblLocation AS L
			ON L.SysLocationId = COL.SysLocationID
		LEFT JOIN dbo.tblAccountC AS A
			ON A.SysClaimID = COL.SysClaimIDOrig
		LEFT JOIN dbo.tblAccountC_Insurance AS AI
			ON AI.SysAccountcId = A.SysAccountcId
		LEFT JOIN dbo.tblAccountC_Insurance AS AIL
			ON AIL.SysAccountcId = A.SysAccountcId
			AND AIL.PayerOrder < AI.PayerOrder
		LEFT JOIN dbo.tblInsurance AS I
			ON I.InsuranceId = AI.InsuranceId
	WHERE AIL.SysAccountcId IS NULL


	-- ClaimActionInfo
	SELECT
		COL.CollectionClaimInfoID,
		CS.SysCollectSID,
		COL.ClaimID,
		CS.ActionType AS [Action],
		CS.ActionDate,
		CS.CompletedDate AS CompletedActionDate,
		AU.ModifiedDate AS ActionModifiedDate,
		AU.ModifiedUser AS ActionModifiedUser,
		CS.Comments AS Comment
	FROM
		@CollectionsList AS COL
		INNER JOIN dbo.tblCollects AS CS
			ON CS.SysClaimId = COL.SysClaimID
		LEFT JOIN (
			SELECT
				ModifiedDate,
				ModifiedUser,
				SysCollectSID,
				ROW_NUMBER() OVER(PARTITION BY SysCollectSID ORDER BY ModifiedDate DESC) AS RowNumber
			FROM dbo.tblCollects_Audit
		) AS AU
			ON AU.SysCollectSID = CS.SysCollectSID
			AND AU.RowNumber = 1
		LEFT JOIN (
			SELECT DISTINCT
				SysCollectSID
			FROM
				dbo.tblCollects_Audit
			WHERE ModifiedDate BETWEEN @fromDate AND @toDate
		) AS CSA
			ON CSA.SysCollectSID = CS.SysCollectSID
	WHERE
		COALESCE(@fromDate, @toDate) IS NULL
		OR CSA.SysCollectSID IS NOT NULL
		
	-- CollectionCollectorInfo
	SELECT DISTINCT
		COL.CollectionID,
		C.CollectorID,
		CC.CollectOrder
	FROM
		@CollectionsList AS COL
		INNER JOIN dbo.tblCollections_Collector AS CC
			ON CC.SysCollectionId = COL.SysCollectionId
		INNER JOIN dbo.tblCollector AS C
			ON C.SysCollectorId = CC.SysCollectorID

			
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_WorkfileControlValue') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_WorkfileControlValue
GO

/**************************************************************************
 * Function Name:     dbo.usp_SBC_WorkfileControlValue
 * 
 * Purpose: Returns control value of workfile for SBC API.
 * 
 * Rules:
 * 
 * Parameters:
 * 
 * Called By:   SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_WorkfileControlValue
AS
BEGIN
 SELECT TOP 1 ControlValue FROM tblControl WHERE ControlID = 'WORKFILE'
END;
GO


IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_MappingSP') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_MappingSP

GO

/**************************************************************************
 * Proc Name:     dbo.usp_SBC_SELECT_MappingSP
 * 
 * Purpose:       Stab stored procedure for EF mapping.
 * 
 * Rules:
 * 
 * Parameters:
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

CREATE PROC dbo.usp_SBC_SELECT_MappingSP

AS

Select 1

GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_PatientsShortInfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_PatientsShortInfo

GO
/**************************************************************************
 * Proc Name:    dbo.usp_SBC_SELECT_PatientsShortInfo
 * 
 * Purpose:      Returns the list of short patient information for SBC API.
 * 
 * Rules:
 * 
 * Parameters:   UserID			VARCHAR(255)- The user id who performs this operation.
 *			 	 ComputerName	VARCHAR(20) - Machine name where SBC API is running.
 *				 PatientDeptIDs XML			- List of patient identifiers with associated department identifiers.
 * Returns:      List of short patient information.
 * 
 * Called By:	 SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_SELECT_PatientsShortInfo
    @UserID		VARCHAR(255),
    @ComputerName VARCHAR(20),
	@PatientDeptIDs XML
AS

DECLARE @SysPatientID INT

BEGIN TRY
	BEGIN TRANSACTION;

      SELECT 
       [PatientId] = tblPatient.PatientId,
       [DepartmentId] = tblPatient_Insurance.DepartmentID,
       [PatFullName] = tblPatient.PatFullName,
       [PatFirstName] = tblPatient.PatFirstName,
       [PatLastName] = tblPatient.PatLastName,
       [PatMiddleInitial] = tblPatient.PatMiddleInitial,
       [Credentials] = tblPatient.[Credentials],
       [InsuranceID] = tblInsurance.InsuranceID
       from tblPatient
       join
          (SELECT
		  T.N.value('(@PatientId[1])', 'varchar(20)') as patientId,
		  T.N.value('(@DepartmentId[1])', 'int') as deptid 
		  FROM @PatientDeptIDs.nodes('//Patients/Patient') as T(N)) patDept ON tblPatient.PatientID = patDept.patientId
			LEFT join  dbo.tblPatient_Insurance ON tblPatient.SysPatId = tblPatient_Insurance.SysPatId 
				AND tblPatient_Insurance.PayorOrder in 
					(SELECT min(PayorOrder) from dbo.tblPatient_Insurance 
						WHERE tblPatient.SysPatId = tblPatient_Insurance.SysPatId
						AND (tblPatient_Insurance.DepartmentID = deptid OR deptid IS NULL))
			LEFT JOIN dbo.tblInsurance
				ON tblInsurance.SysInsuranceId = tblPatient_Insurance.SysInsuranceId	  

	--IF @SysPatientID IS NOT NULL
	--INSERT INTO tblHCAL (
	--	HCALID,
	--	ApplicationName, 
	--	OperatorID, 
	--	HCALDateTime, 
	--	ComputerName, 
	--	ThreadId, 
	--	[Type], 
	--	PatientID, 
	--	DepartmentID, 
	--	Duration, 
	--	PrinterName, 
	--	FormName, 
	--	ItemId
	--)	 
	--VALUES (
	--	ISNULL((SELECT MAX(HCALID) + 1 FROM tblHCAL), 1),
	--	'SBCAPI', 
	--	@UserID,
	--	GETDATE(),
	--	@ComputerName, 
	--	NULL, 
	--	1, 
	--	@PatientID, 
	--	@DeptID, 
	--	NULL, 
	--	NULL, 
	--	NULL, 
	--	@PatientId 
	--) 

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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_RTUsers') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_RTUsers
GO

/**************************************************************************
 * Proc Name:    dbo.usp_SBC_SELECT_RTUsers
 * 
 * Purpose:      Returns list of active users for SBC API.
 * 
 * Rules:
 * 
 * Parameters:   UserID			VARCHAR(255)- The user id who performs this operation.
 *			 	 ComputerName	VARCHAR(20) - Machine name where SBC API is running.
 * Returns:      List of active users.
 * 
 * Called By:	 SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_SELECT_RTUsers
    @UserID			VARCHAR(255),
    @OperatorID		VARCHAR(24) = NULL,
    @ComputerName	VARCHAR(20)
AS

BEGIN TRY
	BEGIN TRANSACTION;

	-- RTUserInfo
	SELECT
		O.OperatorID,
		O.OperatorName,
		GETDATE() AS EntityTimeStamp,
		O.Address1 AS [Address],
		O.Phone,
		O.[Password],
		O.Zip,
		O.IsMustChangePW,
		O.IsAccountDisabled,
		O.IsPopupCollection,
		C.CollectorID,
		O.DefaultCollectionsActivity
	FROM
		dbo.tblOperator AS O
		LEFT JOIN dbo.tblCollector AS C
			ON C.SysCollectorId = O.SysCollectorID
		LEFT JOIN (
			SELECT
				ModifiedDate,
				ModifiedUser,
				SysOperatorID,
				ROW_NUMBER() OVER(PARTITION BY SysOperatorID ORDER BY ModifiedDate DESC) AS RowNumber
			FROM dbo.tblOperator_Audit
		) AS OU
			ON OU.SysOperatorID = O.SysOperatorId
			AND OU.RowNumber = 1
	WHERE
		O.OperatorID = @OperatorID
		OR @OperatorID IS NULL
			
	-- RTUserGroups
	SELECT
		O.OperatorID,
		G.OperatorGroupID
	FROM
		dbo.tblOperator AS O
		INNER JOIN dbo.tblOperatorGroups AS OG
			ON OG.SysOperatorID = O.SysOperatorId
		INNER JOIN dbo.tblOperatorGroup AS G
			ON G.SysOpGroupId = OG.SysOpGroupId
	WHERE
		O.OperatorID = @OperatorID
		OR @OperatorID IS NULL
	
	--RTUserClaimForm
	SELECT
		CF.SysOperatorClaimFormID,
		CF.ClaimForm,
		CF.ClaimPrinter,
		CF.ClaimPrinterTray,
		OP.OperatorID
		
	FROM
		dbo.tblOperatorClaimForm AS CF
		JOIN dbo.tblOperator AS OP
			ON OP.SysOperatorId = CF.SysOperatorID
	WHERE OP.OperatorID = @OperatorID
		OR @OperatorID IS NULL
	
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_RTUserGroups') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_RTUserGroups
GO

/**************************************************************************
 * Proc Name:    dbo.usp_SBC_SELECT_RTUserGroups
 * 
 * Purpose:      Retreives list of user groups from RT system for SBC API.
 * 
 * Rules:
 * 
 * Parameters:   UserID			VARCHAR(255)- The user id who performs this operation.
 *			 	 ComputerName	VARCHAR(20) - Machine name where SBC API is running.
 * Returns:      List of user groups.
 * 
 * Called By:	 SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_SELECT_RTUserGroups
    @UserID			VARCHAR(255),
    @ComputerName	VARCHAR(20)
AS

BEGIN TRY
	BEGIN TRANSACTION;

	-- RTUserGroups
	SELECT
		OperatorGroupID,
		OperatorDescription
	FROM dbo.tblOperatorGroup
	
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_RTUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_CREATE_RTUser
GO

/**************************************************************************
 * Proc Name:   dbo.usp_SBC_CREATE_RTUser
 * 
 * Purpose:		Creates new user in RT system.
 * 
 * Rules:
 * 
 * Parameters:
 *	   UserID						VARCHAR(255)	- The user id who performs this operation.
 *     ComputerName					VARCHAR(20)		- Machine name where SBC API is running.
 *     OperatorId					VARCHAR(24)		- Operators id.
 *     OperatorName					VARCHAR(999)	- Operators name.
 *     EntityTimestamp				DateTime		- Entity time stamp.
 *     Address						VARCHAR(999)	- primary operator's address.
 *     Phone						VARCHAR(12)		- operators phone.
 *     Password						VARCHAR(12)		- operators password.
 *     Zip							VARCHAR(50)		- operators zip.
 *     IsMustChangePW				BIT				- is must change pw.
 *     IsAccountDisabled			BIT				- is account disable.
 *     IsPopupCollection			BIT				- is popup collection.
 *     CollectorId					VARCHAR(10)		- collector id.
 *     DefaultCollectionsActivity	VARCHAR(30)		- Default collections activity.
 *     IsCannotChangePW				BIT				- Is cannot change pw.
 * 
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_CREATE_RTUser
    @UserID						VARCHAR(255),
    @OperatorId					VARCHAR(24),
    @OperatorName				VARCHAR(999),
    @EntityTimestamp			DateTime,
    @Address					VARCHAR(999),
    @Phone						VARCHAR(12),
    @Password					VARCHAR(12),
    @Zip						VARCHAR(50),
    @IsMustChangePW				BIT,
    @IsAccountDisabled			BIT,
	@IsPopupCollection			BIT,
	@CollectorId				VARCHAR(10), 
    @DefaultCollectionsActivity VARCHAR(30),
    @IsCannotChangePW			BIT,
    @ComputerName				VARCHAR(20)
AS

DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;
BEGIN TRY	

IF EXISTS(
	SELECT 1
	FROM dbo.tblOperator
	WHERE OperatorID = @OperatorID
)
RAISERROR (50104, 16, 1)

DECLARE
	@SysOperatorID INT,
	@SysCollectorID INT

Set @SysCollectorID = (SELECT SysCollectorID FROM dbo.tblCollector WHERE CollectorID = @CollectorID)

	IF EXISTS(
		SELECT 1
		FROM dbo.tblOperator
		WHERE OperatorID = @OperatorID
	)
	RAISERROR (50104, 16, 1)

	IF @SysCollectorID IS NULL
		AND @CollectorId IS NOT NULL
	RAISERROR (50103, 16, 1)

	INSERT INTO dbo.tblOperator (
		OperatorID,
		OperatorName,
		Address1,
		Phone,
		[Password],
		Zip,
		IsMustChangePW,
		IsAccountDisabled,
		IsPopupCollection,
		SysCollectorID,
		DefaultCollectionsActivity,
		IsCannotChangePW
		)
	VALUES (
		@OperatorId,
		@OperatorName,
		@Address,
		@Phone,
		@Password,
		@Zip,
		@IsMustChangePW,
		@IsAccountDisabled,
		@IsPopupCollection,
		@SysCollectorID,
		@DefaultCollectionsActivity,
		@IsCannotChangePW
		)
	
		Set @SysOperatorID = (SELECT SysOperatorID FROM dbo.tblOperator WHERE OperatorID = @OperatorId)
		
		-- dbo.tblOperator_Audit
		INSERT INTO dbo.tblOperator_Audit (
			SysOperatorID,
			ModIFiedUser,
			ModIFiedDate
			)
		VALUES (
			@SysOperatorID,
			@UserID,
			GETDATE()
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_RTUserLocations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_CREATE_RTUserLocations
GO
/**************************************************************************
 * Proc Name:  dbo.usp_SBC_CREATE_RTUserLocations
 * 
 * Purpose:    Creates association between location and existing user in RT system.
 * 
 * Rules:
 * 
 * Parameters:
 *		UserID		 VARCHAR(255)- The user id who performs this operation.
 *      ComputerName VARCHAR(20) - Machine name where SBC API is running.
 *		OperatorId   VARCHAR(24) - Operator id.
 *		LocationID   VARCHAR(25) - Location id.
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_CREATE_RTUserLocations
    @UserID			VARCHAR(255),     
    @ComputerName	VARCHAR(20),
    @OperatorId		VARCHAR(24),
    @LocationID		VARCHAR(25)
AS
DECLARE
	@SysOperatorID INT,
	@SysLocationID INT

Set @SysOperatorID = (SELECT SysOperatorID FROM dbo.tblOperator WHERE OperatorID = @OperatorId)
Set @SysLocationID = (SELECT SysLocationID FROM dbo.tblLocation WHERE LocationID = @LocationID)

INSERT INTO dbo.tblOperatorLocations (
	SysOperatorID,
	SysLocationID
	)
VALUES (
	@SysOperatorID,
	@SysLocationID
	)

GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_RTUserGroups') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_CREATE_RTUserGroups
GO
/**************************************************************************
 * Proc Name:  dbo.usp_SBC_CREATE_RTUserGroups
 * 
 * Purpose:    Creates association between user group and existing user in RT system.
 * 
 * Rules:
 * 
 * Parameters:
 *		UserID			VARCHAR(255)- The user id who performs this operation.
 *      ComputerName	VARCHAR(20) - Machine name where SBC API is running.
 *		OperatorId		VARCHAR(24) - Operator id.
 *		GroupID			VARCHAR(25) - Ground id.
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_CREATE_RTUserGroups
    @UserID			VARCHAR(255),     
    @ComputerName	VARCHAR(20),
    @OperatorId		VARCHAR(24),
    @GroupID		VARCHAR(25)
AS

BEGIN TRY
	BEGIN TRANSACTION;
	
	IF NOT EXISTS (
		SELECT 1
		FROM dbo.tblOperatorGroup
		WHERE OperatorGroupID = @GroupID
	)
	RAISERROR (50103, 16, 1)
	
DECLARE
	@SysOperatorID	INT,
	@SysOpGroupId	INT

Set @SysOperatorID = (SELECT SysOperatorID FROM dbo.tblOperator WHERE OperatorID = @OperatorId)
Set @SysOpGroupId = (SELECT SysOpGroupId FROM dbo.tblOperatorGroup WHERE OperatorGroupID = @GroupID)

INSERT INTO dbo.tblOperatorGroups (
	SysOperatorID,
	SysOpGroupId
	)
VALUES (
	@SysOperatorID,
	@SysOpGroupId
	)
	
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_RTUserClaimForm') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_CREATE_RTUserClaimForm
GO
/**************************************************************************
 * Proc Name:    dbo.usp_SBC_CREATE_RTUserClaimForm
 * 
 * Purpose:      Creates new claim form for the user.
 * 
 * Rules:
 * 
 * Parameters:
 *		UserID			VARCHAR(255)- The user id who performs this operation.
 *      ComputerName	VARCHAR(20) - Machine name where SBC API is running.
 *		OperatorId		VARCHAR(24) - Operator id.
 *		ClaimForm		VARCHAR(24) - Operator Claim form
 *      ClaimPrinter    VARCHAR(255)- Operator printer description
 *      ClaimPrinterTray  SMALLINT  - Operator printer tray
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_CREATE_RTUserClaimForm
    @UserID			VARCHAR(255),
    @ComputerName	VARCHAR(20),
    @OperatorId		VARCHAR(24),
    @ClaimForm		VARCHAR(24),
    @ClaimPrinter   VARCHAR(255),
    @ClaimPrinterTray SMALLINT
AS

IF NOT EXISTS (
	SELECT 1
	FROM
		dbo.tblSystemTables AS ST
		INNER JOIN dbo.tblSystemTableDetails STD
			ON STD.SysTablesID = ST.SysTablesID
	WHERE
		ST.TablesID = 'CLAIM.FORMS'
		AND STD.Code = COALESCE(@ClaimForm, STD.Code)
	)
RAISERROR(50103, 16, 1)

DECLARE
	@SysOperatorID int;
	
Set @SysOperatorID = (SELECT SysOperatorID FROM dbo.tblOperator WHERE OperatorID = @OperatorId)

INSERT INTO [dbo].[tblOperatorClaimForm]
           (SysOperatorID
           ,ClaimForm
           ,ClaimPrinter
           ,ClaimPrinterTray)
     VALUES
           (@SysOperatorID,
            @ClaimForm,
		    @ClaimPrinter,
			@ClaimPrinterTray)
GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_DELETE_RTUserClaimForms') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_DELETE_RTUserClaimForms
GO
/**************************************************************************
 * Proc Name:    dbo.usp_SBC_DELETE_RTUserClaimForms
 * 
 * Purpose:      Delete all claim forms of the user.
 * 
 * Rules:
 * 
 * Parameters:
 *		UserID			VARCHAR(255)- The user id who performs this operation.
 *      ComputerName	VARCHAR(20) - Machine name where SBC API is running.
 *		OperatorId		VARCHAR(24) - Operator id.
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_DELETE_RTUserClaimForms
    @UserID			VARCHAR(255),
    @ComputerName	VARCHAR(20),
    @OperatorId		VARCHAR(24)
AS
DECLARE
	@SysOperatorID int;

Set @SysOperatorID = (SELECT SysOperatorID FROM dbo.tblOperator WHERE OperatorID = @OperatorId)

DELETE FROM [dbo].[tblOperatorClaimForm]
	WHERE SysOperatorID = @SysOperatorID
GO


IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_UPDATE_RTUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_UPDATE_RTUser
GO

/**************************************************************************
 * Proc Name:  dbo.usp_SBC_UPDATE_RTUser
 * 
 * Purpose:    Updates user in RT system.
 * 
 * Rules:
 * 
 * Parameters:
 *		UserID						VARCHAR(255)	- The user id who performs this operation.     
 *		OperatorId					VARCHAR(24)		- Operator's id.
 *		OperatorName				VARCHAR(999)	- Operator's name.
 *		EntityTimestamp				DATETIME		- Entity time stamp.
 *		Address1					VARCHAR(999)	- Operator's address.
 *		Phone						VARCHAR(12)		- Operator's phone.
 *		Password					VARCHAR(12)		- Operator's password.
 *		Zip							VARCHAR(50)		- Operator's zip.
 *		IsMustChangePW				BIT				- Is must change pw.
 *		IsAccountDisabled			BIT				- Is account disable.
 *		IsPopupCollection			BIT				- Is popup collection.
 *		CollectorId					VARCHAR(10)		- Collector id.
 *		DefaultCollectionsActivity	VARCHAR(30)		- Default collections activity.
 *		ComputerName				VARCHAR(20)		- Machine name where SBC API is running.
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_UPDATE_RTUser  
    @UserID    VARCHAR(255),
    @OperatorId   VARCHAR(24),
    @OperatorName  VARCHAR(999),
    @EntityTimestamp DateTime,
    @Address   VARCHAR(999),
    @Phone    VARCHAR(12),
    @Password      VARCHAR(12),
    @Zip    VARCHAR(50),
    @IsMustChangePW  BIT,
    @IsAccountDisabled BIT,
	@IsPopupCollection BIT,
	@CollectorId  VARCHAR(10), 
    @DefaultCollectionsActivity VARCHAR(30),
    @ComputerName  VARCHAR(20)
AS

DECLARE
	@SysOperatorID INT,
	@SysCollectorID INT

Set @SysOperatorID = (SELECT SysOperatorID FROM dbo.tblOperator WHERE OperatorID = @OperatorId)
Set @SysCollectorID = (SELECT SysCollectorID FROM dbo.tblCollector WHERE CollectorID = @CollectorID)

DECLARE @SysFeeScheduleId INT

DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;
        
BEGIN TRY
	
IF NOT EXISTS (
	SELECT 1
	FROM dbo.tblOperator
	WHERE SysOperatorId = @SysOperatorID
)
RAISERROR (50102, 16, 1)

	IF @SysCollectorID IS NULL
		AND @CollectorId IS NOT NULL
	RAISERROR (50103, 16, 1)
 
	IF EXISTS (
		SELECT 1
		FROM dbo.tblOperator_Audit
		WHERE
			SysOperatorID = @SysOperatorID
			AND ModifiedDate > ISNULL(@EntityTimeStamp, CONVERT(DATETIME, 0))
	)
	RAISERROR (50101, 16, 1)
	
	UPDATE dbo.tblOperator
	SET
		OperatorName = @OperatorName,
		Address1 = @Address,
		Phone = @Phone,
		Password = @Password,
		Zip = @Zip,
		IsMustChangePW = @IsMustChangePW,
		IsAccountDisabled = @IsAccountDisabled,
		IsPopupCollection = @IsPopupCollection,
		SysCollectorID = @SysCollectorID,
		DefaultCollectionsActivity = @DefaultCollectionsActivity
	WHERE
		SysOperatorID = @SysOperatorID
	
	-- dbo.tblOperator_Audit
	INSERT INTO dbo.tblOperator_Audit (
		SysOperatorID,
		ModIFiedUser,
		ModIFiedDate
		)
	VALUES (
		@SysOperatorID,
		@UserID,
		GETDATE()
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_DELETE_RTUserGroups') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_DELETE_RTUserGroups
GO

/**************************************************************************
 * Proc Name:  dbo.usp_SBC_DELETE_RTUserGroups
 * 
 * Purpose:      Delete user from all groups.
 * 
 * Rules:
 * 
 * Parameters:
 *		UserID						VARCHAR(255)	- The user id who performs this operation.     
 *		OperatorId					VARCHAR(24)		- Operator's id.
 *		ComputerName				VARCHAR(20)		- Machine name where SBC API is running.
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_DELETE_RTUserGroups
    @UserID    VARCHAR(255),
    @OperatorId   VARCHAR(24),
    @ComputerName  VARCHAR(20)
AS

DECLARE @SysOperatorID INT

SET @SysOperatorID = (SELECT SysOperatorID FROM dbo.tblOperator WHERE OperatorID = @OperatorId)

	--RTUserGroups
	DELETE
	FROM dbo.tblOperatorGroups
	WHERE SysOperatorID = @SysOperatorID
GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_FeeSchedules') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_FeeSchedules
GO

/**************************************************************************
 * Proc Name:  dbo.usp_SBC_SELECT_FeeSchedules
 * 
 * Purpose:    Retreives list of fee schedules from RT system.
 * 
 * Rules:
 * 
 * Parameters:
 *			UserID	VARCHAR(255)	- The user id who performs this operation.
 *			FeesID	VARCHAR(999)	- Fee schedule Id.
 * 
 * Returns: List of fee schedules.
 *
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_SELECT_FeeSchedules
	@UserID	VARCHAR(255),
	@FeesID	VARCHAR(999) = NULL
AS

DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;
BEGIN TRY	
	
	-- FeeScheduleInfo
	SELECT
		FeesID,
		[Description],
		ContractPercent,
		CapUnitRate,
		@UserID AS UserID,
		IsApplyChrgPercent,
		IsApplyCostPercent,
		GETDATE() AS EntityTimestamp
	FROM  dbo.tblFeeSchedule
	WHERE
		FeesID = @FeesID
		OR @FeesID IS NULL

	-- FeeScheduleItemInfo
	SELECT
		NEWID() as Id,
		S.FeesID,
		H.HCPCID,
		SI.Price,
		SI.Cost,
		SI.Customary,
		SI.Allowable,
		SI.FromDate,
		SI.ToDate,
		SI.MinimumUnits,
		SI.MaximumUnits,
		SI.DefaultUnits,
		@UserID AS UserID
	FROM
		dbo.tblFeeSchedule AS S
		INNER JOIN dbo.tblFeeSchedule_HCPC AS SI
			ON SI.SysFeeScheduleId = S.SysFeeScheduleId
		INNER JOIN dbo.tblHCPC AS H
			ON H.SysHCPCID = SI.SysHCPCID
	WHERE
		S.FeesID = @FeesID
		OR @FeesID IS NULL
	
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_FeeSchedule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_CREATE_FeeSchedule
GO

/**************************************************************************
 * Proc Name:  dbo.usp_SBC_CREATE_FeeSchedule
 * 
 * Purpose:    Creates fee schedule in RT system.
 * 
 * Rules:         
 * 
 * Parameters:
 *		UserID				VARCHAR(255)	- The user id who performs this operation.
 *		FeesID				VARCHAR(999)	- Fee schedule Id.
 *      Description			VARCHAR(999)	- Fee schedule description.
 *      ContractPercent		NUMERIC(8,4)	
 *      CapUnitRate			MONEY
 *      IsApplyChrgPercent	BIT
 *      IsApplyCostPercent	BIT
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes: The entity ID is sent to the service in the entity object.
 *		  Service caller is responsible for generating unique ID for creating new record.
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_CREATE_FeeSchedule
	@UserID				VARCHAR(255),
	@FeesID				VARCHAR(999),
	@Description		VARCHAR(999),
	@ContractPercent	NUMERIC(8,4),	
	@CapUnitRate		MONEY,
	@IsApplyChrgPercent	BIT,
	@IsApplyCostPercent	BIT
AS

DECLARE @SysFeeScheduleId INT

DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    IF @TranCounter > 0
        SAVE TRANSACTION ProcedureSave;
    ELSE
        BEGIN TRANSACTION;
BEGIN TRY	
	
	IF EXISTS (
		SELECT 1
		FROM dbo.tblFeeSchedule
		WHERE FeesID = @FeesID
	)
	RAISERROR(50104, 16, 1)
	
	INSERT INTO dbo.tblFeeSchedule (
		FeesID,
		[Description],
		ContractPercent,
		CapUnitRate,
		IsApplyChrgPercent,
		IsApplyCostPercent
	)
	VALUES (
		@FeesID,
		@Description,
		@ContractPercent,
		@CapUnitRate,
		@IsApplyChrgPercent,
		@IsApplyCostPercent
	)

	SET @SysFeeScheduleId = SCOPE_IDENTITY()

	INSERT INTO dbo.tblFeeschedule_Audit (
		SysFeeScheduleId,
		ModifiedUser,
		ModifiedDate
	)
	VALUES(
		@SysFeeScheduleId,
		@UserID,
		GETDATE()
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_CREATE_FeeScheduleItem') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_CREATE_FeeScheduleItem
GO

/**************************************************************************
 * Proc Name:  dbo.usp_SBC_CREATE_FeeScheduleItem
 * 
 * Purpose:    Creates fee schedule item data in RT system.
 * 
 * Rules:         
 * 
 * Parameters:
 *		UserID			VARCHAR(255)	- The user id who performs this operation.
 *		FeesID			VARCHAR(999)	- Fee schedule Id.
 *      HCPCId			VARCHAR(20)		- HCPC Id.
 *      Price			MONEY			
 *      Cost			MONEY
 *      Customary		MONEY
 *      Allowable		MONEY
 *		FromDate		DATETIME		 
 *		ToDate			DATETIME		
 *		MinimumUnits	NUMERIC(10,2)	
 *		MaximumUnits	NUMERIC(10,2)
 *		DefaultUnits	NUMERIC(10,2)
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes: The entity ID is sent to the service in the entity object.
 *		  Service caller is responsible for generating unique ID for creating new record.
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_CREATE_FeeScheduleItem
    @UserID			VARCHAR(255),
	@FeesID			VARCHAR(999),
	@HCPCId			VARCHAR(20),
	@Price			MONEY,
	@Cost			MONEY,
	@Customary		MONEY,
	@Allowable		MONEY,
	@FromDate		DATETIME,
	@ToDate			DATETIME,
	@MinimumUnits	NUMERIC(10,2),
	@MaximumUnits	NUMERIC(10,2),
	@DefaultUnits	NUMERIC(10,2)
    
AS
	
DECLARE	@SysFeeScheduleId INT
DECLARE	@SysHCPCID INT

SET @SysFeeScheduleId = (
	SELECT TOP 1 SysFeeScheduleId
	FROM dbo.tblFeeSchedule
	WHERE FeesID = @FeesID)
	
SET @SysHCPCID = (
	SELECT TOP 1 SysHCPCID
	FROM dbo.tblHCPC
	WHERE HCPCID = @HCPCId
)
	
IF @SysFeeScheduleId IS NULL
BEGIN
	RAISERROR(50102, 16, 1)
	RETURN
END

IF @SysHCPCID IS NULL
BEGIN
	RAISERROR(50103, 16, 1)
	RETURN
END

IF EXISTS (
	SELECT 1
	FROM dbo.tblFeeSchedule_HCPC
	WHERE
		SysFeeScheduleId = @SysFeeScheduleId
		AND SysHCPCID = @SysHCPCID
)
BEGIN
	RAISERROR(50106, 16, 1)
	RETURN
END

INSERT INTO dbo.tblFeeSchedule_HCPC (
	SysFeeScheduleId,
	SysHCPCID,
	Price,
	Cost,
	Customary,
	Allowable,
	FromDate,
	ToDate,
	MinimumUnits,
	MaximumUnits,
	DefaultUnits
)
VALUES (
	@SysFeeScheduleId,
	@SysHCPCID,
	@Price,
	@Cost,
	@Customary,
	@Allowable,
	@FromDate,
	@ToDate,
	@MinimumUnits,
	@MaximumUnits,
	@DefaultUnits
)

GO

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_DELETE_FeeScheduleItems') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_DELETE_FeeScheduleItems
GO
/**************************************************************************
 * Proc Name:    dbo.usp_SBC_DELETE_FeeScheduleItems
 * 
 * Purpose:      Delete all FeeSchedule items forms of the user.
 * 
 * Rules:         
 * 
 * Parameters:
 *		UserID			VARCHAR(255)- The user id who performs this operation.
 *		OperatorId		VARCHAR(24) - Operator id.
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_DELETE_FeeScheduleItems
    @UserID			VARCHAR(255),
    @FeesID		    VARCHAR(999)
AS
	
DECLARE	@SysFeeScheduleId INT

SET @SysFeeScheduleId = (
	SELECT TOP 1 SysFeeScheduleId
	FROM dbo.tblFeeSchedule
	WHERE FeesID = @FeesID)

DELETE FROM [dbo].[tblFeeSchedule_HCPC]  
	WHERE SysFeeScheduleId = @SysFeeScheduleId
GO


IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_UPDATE_FeeSchedule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_UPDATE_FeeSchedule
GO

/**************************************************************************
 * Proc Name:  dbo.usp_SBC_UPDATE_FeeSchedule
 * 
 * Purpose:    Creates fee schedule item data in RT system.
 * 
 * Rules:         
 * 
 * Parameters:
 *		 	@UserID				VARCHAR(255)
 *			@FeesID				VARCHAR(999)
 *			@Description		VARCHAR(999)
 *			@ContractPercent	NUMERIC(8,4)
 *			@CapUnitRate		MONEY
 *			@IsApplyChrgPercent	BIT
 *			@IsApplyCostPercent	BIT
 *			@EntityTimestamp	DateTime
 * 
 * Called By:  SBC API
 * 
 * Calls:
 *
 * Notes: The entity ID is sent to the service in the entity object.
 *		  Service caller is responsible for generating unique ID for creating new record.
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_UPDATE_FeeSchedule
  	@UserID				VARCHAR(255),
	@FeesID				VARCHAR(999),
	@Description		VARCHAR(999),
	@ContractPercent	NUMERIC(8,4),	
	@CapUnitRate		MONEY,
	@IsApplyChrgPercent	BIT,
	@IsApplyCostPercent	BIT,
    @EntityTimestamp DateTime
AS
	
DECLARE	@SysFeeScheduleId INT
SET @SysFeeScheduleId = (SELECT TOP 1 SysFeeScheduleId FROM dbo.tblFeeSchedule WHERE FeesID = @FeesID)	


DECLARE @TranCounter INT;
SET @TranCounter = @@TRANCOUNT;
IF @TranCounter > 0
	SAVE TRANSACTION ProcedureSave;
ELSE
	BEGIN TRANSACTION;
	
    BEGIN TRY
	
	IF NOT EXISTS (
		SELECT 1
		FROM dbo.tblFeeSchedule
		WHERE SysFeeScheduleId = @SysFeeScheduleId
	)
	RAISERROR (50102, 16, 1)

	IF EXISTS (
	SELECT 1
	FROM dbo.tblFeeschedule_Audit
	WHERE
		SysFeeScheduleId = @SysFeeScheduleId
		AND ModifiedDate > ISNULL(@EntityTimeStamp, CONVERT(DATETIME, 0))
	)
	RAISERROR (50101, 16, 1)
	
	UPDATE dbo.tblFeeSchedule
	SET
		Description= @Description,
		ContractPercent = @ContractPercent,
		tblFeeSchedule.CapUnitRate = @CapUnitRate,
		IsApplyChrgPercent = @IsApplyChrgPercent,
		IsApplyCostPercent = @IsApplyCostPercent	
	WHERE SysFeeScheduleId = @SysFeeScheduleId
	
	-- dbo.tblFeeschedule_Audit
	INSERT INTO dbo.tblFeeschedule_Audit (
		SysFeeScheduleId,
		ModIFiedUser,
		ModIFiedDate
		)
	VALUES (
		@SysFeeScheduleId,
		@UserID,
		GETDATE()
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

IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.usp_SBC_SELECT_HCPC') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE dbo.usp_SBC_SELECT_HCPC
GO

/**************************************************************************
 * Proc Name:    dbo.usp_SBC_SELECT_HCPC
 * 
 * Purpose:      Retreives list of active HCPC codes from RT system for SBC API.
 * 
 * Rules:         
 * 
 * Parameters:   UserID	VARCHAR(255)- The user id who performs this operation.
 * Returns:      List of active HCPC codes.
 * 
 * Called By:	 SBC API
 * 
 * Calls:
 *
 * Notes:
 * 
 * Modifications:
 * 
 ***************************************************************************/

CREATE PROC dbo.usp_SBC_SELECT_HCPC
    @UserID	VARCHAR(255)
AS

SELECT
	HCPCID,
	[Description],
	ShortDescription,
	Price,
	Cost,
	CustomaryFee,
	AllowableFee,
	RelativeValueUnit,
	UnitConvert,
	SubstituteCode,
	LessPrice,
	IsBillCode,
	CodeTypeID,
	RevenueCode,
	PrintCodeText,
	IsTaxable,
	MinUnits,
	MaxUnits,
	DefaultUnits,
	IsDME
FROM dbo.tblHCPC

GO