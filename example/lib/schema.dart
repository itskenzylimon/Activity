
class SchemaData{
  final Map schema = {
    "completedHtml": "<h3>Record submission successful</h3>",
    "pages": [
      {
        "elements": [
          {
            "name": "OrganizationName",
            "readOnly": true,
            "title": "Organization Name",
            "type": "text"
          },
          {
            "name": "OrganizationRegistrationNumber",
            "readOnly": true,
            "startWithNewLine": false,
            "title": "Organization Registration Number",
            "type": "text"
          },
          {"name": "County", "readOnly": true, "title": "County", "type": "text"},
          {
            "name": "SubCounty",
            "readOnly": true,
            "startWithNewLine": false,
            "title": "Sub County",
            "type": "text"
          },
          {
            "elements": [
              {"name": "InformantFullName", "title": "Full Name", "type": "text"},
              {
                "name": "InformantIdentificationNumber1",
                "startWithNewLine": false,
                "title": "Identification Number",
                "type": "text"
              },
              {
                "inputType": "number",
                "name": "InformantPhoneNumber",
                "placeholder": "+254700000000",
                "title": "Phone Number",
                "type": "text"
              },
              {
                "inputType": "email",
                "name": "InformantEmailAddress",
                "placeholder": "abc@xyz.com",
                "startWithNewLine": false,
                "title": "Email Address",
                "type": "text"
              },
              {
                "name": "InformantDesignation",
                "placeholder": "eg medical practitioner",
                "title": "Designation",
                "type": "text"
              }
            ],
            "name": "InformantDetails",
            "title": "Informant Details",
            "type": "panel",
            "visible": false
          },
          {
            "choices": ["NO", "YES"],
            "description": "(Mandatory)",
            "isRequired": true,
            "name": "IsthechildAbandoned",
            "title": "Is this a registration relating to an Abandoned child?",
            "type": "radiogroup"
          }
        ],
        "name": "General Information",
        "title": "General Information"
      },
      {
        "elements": [
          {
            "elements": [
              {
                "choices": [
                  "Adult (Above 18 years)",
                  "Minor (below 18years)",
                  "Not Able to Access Identification Document"
                ],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "CategoryOfMother",
                "title": "Category Of Mother",
                "type": "dropdown"
              },
              {
                "choices": ["Citizen", "Foreigner", "Alien"],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherTypeofNationality",
                "title": "Type of Nationality",
                "type": "dropdown",
                "visibleIf":
                "{CategoryOfMother} anyof ['Adult (Above 18 years)', 'Minor (below 18years)']"
              },
              {
                "displayTemplate":
                "<h4 class = \"bg-white text-dark border rounded \n p-3\">\nKENYAN\n<h4>",
                "name": "Nationality",
                "title": "Nationality",
                "type": "genericquestion",
                "visibleIf": "{MotherTypeofNationality} anyof ['Citizen']"
              },
              {
                "description": "(Mandatory)",
                "lookupDataTemplateId": "054353fb-9938-4e63-a7ad-a11c3ac83b5e",
                "lookupServiceId": 2,
                "name": "IPRSLookup",
                "outputs": [
                  {
                    "text": "<<result.id_number>>",
                    "value": "MotherIdentificationNumber"
                  },
                  {"text": "<<result.first_name>>", "value": "MotherFirstName"},
                  {"text": "<<result.other_name>>", "value": "MotherMiddleName"},
                  {"text": "<<result.surname>>", "value": "MotherFathersName"},
                  {"text": "<<result.dob>>", "value": "MotherDateofBirth"},
                  {"text": "<<result.dob>>", "value": "motherAgeAtBirth"}
                ],
                "title": "IPRS Lookup",
                "type": "httplookup",
                "visibleIf":
                "{MotherTypeofNationality} anyof ['Citizen', 'Alien'] and {CategoryOfMother} anyof ['Adult (Above 18 years)']"
              },
              {
                "description": "Identification Number/Passport Number",
                "enableIf": "{MotherTypeofNationality} anyof ['Foreigner']",
                "name": "MotherIdentificationNumber",
                "title": "Identification Number",
                "type": "text",
                "visibleIf":
                "{CategoryOfMother} anyof ['Adult (Above 18 years)'] and {MotherTypeofNationality} anyof ['Citizen', 'Alien', 'Foreigner']"
              },
              {
                "enableIf":
                "{MotherTypeofNationality} anyof ['Foreigner'] or {CategoryOfMother} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "isRequired": true,
                "name": "MotherFirstName",
                "title": "First Name",
                "type": "text"
              },
              {
                "enableIf":
                "{MotherTypeofNationality} anyof ['Foreigner'] or {CategoryOfMother} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "name": "MotherMiddleName",
                "startWithNewLine": false,
                "title": "Middle Name",
                "type": "text"
              },
              {
                "enableIf":
                "{MotherTypeofNationality} anyof ['Foreigner'] or {CategoryOfMother} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "isRequired": true,
                "name": "MotherFathersName",
                "startWithNewLine": false,
                "title": "Father's Name",
                "type": "text"
              },
              {
                "description": "(Mandatory)",
                "inputType": "number",
                "isRequired": true,
                "max": "17",
                "min": "1",
                "name": "motherAge",
                "title": "Mother's Age at the time of Birth",
                "type": "text",
                "visibleIf":
                "{CategoryOfMother} anyof ['Minor (below 18years)', 'Not Able to Access Identification Document'] or {MotherTypeofNationality} anyof ['Foreigner']"
              },
              {
                "dateFormat": "MM/DD/YYYY hh:mm:ss",
                "dateInterval": "years",
                "name": "motherAgeAtBirth",
                "readOnly": true,
                "title": "Mother's Age at the time of Birth",
                "type": "agecalc",
                "visibleIf":
                "{CategoryOfMother} anyof ['Adult (Above 18 years)'] and {MotherTypeofNationality} anyof ['Citizen']"
              },
              {
                "choices": ["Married", "Single", "Divorced", "Widowed"],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherMaritalStatus",
                "startWithNewLine": false,
                "title": "Marital Status",
                "type": "dropdown"
              },
              {
                "blockFutureDates": true,
                "name": "MotherDateofBirth",
                "title": "Date Of Birth",
                "type": "bsdatepicker",
                "visible": false
              },
              {
                "choicesByUrl": {
                  "titleName": "text",
                  "url":
                  "https://crs.pesaflow.com/resources/download/nationality",
                  "valueName": "value"
                },
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherNationality",
                "renderAs": "select2",
                "title": "Nationality",
                "type": "dropdown",
                "visibleIf":
                "{MotherTypeofNationality} anyof ['Foreigner', 'Alien']"
              },
              {
                "choices": ["Yes", "No"],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "Hasthemotherpreviouslychangedhername",
                "title": "Has the mother previously changed her name?",
                "type": "dropdown"
              },
              {
                "isRequired": true,
                "name": "InitialFullName",
                "title": "Initial Full Name ",
                "type": "text",
                "visibleIf": "{Hasthemotherpreviouslychangedhername} = 'Yes'"
              },
              {
                "isRequired": true,
                "name": "MotherOccupation",
                "placeholder": "e.g Teacher",
                "title": "Occupation",
                "type": "text"
              },
              {
                "choices": [
                  "Uneducated",
                  "Primary School",
                  "Secondary School",
                  "Certificate",
                  "Diploma",
                  "Undergraduate",
                  "Masters",
                  "PHD"
                ],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherLevelOfEducation",
                "showOtherItem": true,
                "startWithNewLine": false,
                "title": "Level Of Education",
                "type": "dropdown"
              },
              {
                "choicesByUrl": {
                  "titleName": "text",
                  "url": "https://crs.pesaflow.com/resources/download/county",
                  "valueName": "value"
                },
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherCounty",
                "title": "County of Residence",
                "type": "dropdown"
              },
              {
                "choicesByUrl": {
                  "path": "{MotherCounty}",
                  "titleName": "text",
                  "url": "https://crs.pesaflow.com/resources/download/sub-county",
                  "valueName": "value"
                },
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherSubcounty",
                "startWithNewLine": false,
                "title": "Subcounty of Residence",
                "type": "dropdown"
              },
              {
                "name": "MotherUsualResidence",
                "placeholder": "e.g Buru Buru Phase X House Number Y",
                "title": "Usual Residence",
                "type": "comment"
              },
              {
                "isRequired": true,
                "maxErrorText": "Invalid format 12 digits e.g +254700000000",
                "minErrorText": "Invalid format 12 digits e.g +254700000000",
                "name": "motherMobileNumber",
                "placeholder": "+2547200000000",
                "requiredErrorText": "Invalid format 12 digits e.g +254700000000",
                "title": "Mobile Number",
                "type": "text",
                "validators": [
                  {
                    "regex": "^[+][0-9]{12}\$",
                    "text": "Invalid format 12 digits e.g +254700000000",
                    "type": "regex"
                  }
                ]
              },
              {
                "name": "motherEmail",
                "placeholder": "abc@xyz.com",
                "startWithNewLine": false,
                "title": "Email",
                "type": "text"
              },
              {
                "name": "InPatientNumber",
                "title": "In Patient Number",
                "type": "text"
              },
              {
                "acceptedTypes": ".PDF",
                "description": "(PDF)",
                "isRequired": true,
                "name": "bioData",
                "storeDataAsText": false,
                "title": "Attach Passport Bio-Data Page",
                "type": "file",
                "visibleIf": "{MotherTypeofNationality} anyof ['Foreigner']"
              }
            ],
            "name": "Mother",
            "title": "Mother",
            "type": "panel"
          },
          {
            "elements": [
              {
                "choices": [
                  "None",
                  "1",
                  "2",
                  "3",
                  "4",
                  "5",
                  "6",
                  "7",
                  "8",
                  "9",
                  "10",
                  "11",
                  "12",
                  "13",
                  "14",
                  "15",
                  "16",
                  "17",
                  "18",
                  "19",
                  "20"
                ],
                "name": "NumberBornAlive",
                "title": "Number Born Alive",
                "type": "dropdown"
              },
              {
                "choices": [
                  "None",
                  "1",
                  "2",
                  "3",
                  "4",
                  "5",
                  "6",
                  "7",
                  "8",
                  "9",
                  "10",
                  "11",
                  "12",
                  "13",
                  "14",
                  "15",
                  "16",
                  "17",
                  "18",
                  "19",
                  "20"
                ],
                "name": "NumberBornDead",
                "startWithNewLine": false,
                "title": "Number Born Dead",
                "type": "dropdown"
              }
            ],
            "name": "PreviousBirthsToMother",
            "title": "Previous Births To Mother",
            "type": "panel"
          }
        ],
        "name": "Mother's Information",
        "title": "Mother's Information",
        "visibleIf": "{IsthechildAbandoned} anyof ['NO']"
      },
      {
        "elements": [
          {
            "elements": [
              {
                "choices": ["Yes", "No"],
                "name": "named",
                "title": "Has the child been named?",
                "type": "dropdown"
              },
              {
                "name": "ChildFirstName",
                "title": "First Name",
                "type": "text",
                "visibleIf": "{named} anyof ['Yes']"
              },
              {
                "name": "ChildOtherName",
                "startWithNewLine": false,
                "title": "Other  Name(s)",
                "type": "text",
                "visibleIf": "{named} anyof ['Yes']"
              },
              {
                "name": "ChildFathersName",
                "startWithNewLine": false,
                "title": "Fathers Name",
                "type": "text",
                "visibleIf":
                "{named} anyof ['Yes'] and {MotherMaritalStatus} anyof ['Married', 'Divorced', 'Widowed']"
              },
              {
                "blockFutureDates": true,
                "isRequired": true,
                "maxDays": -183,
                "name": "ChildDateOfBirth",
                "title": "Date Of Birth",
                "type": "bsdatepicker"
              },
              {
                "choices": ["Male", "Female"],
                "isRequired": true,
                "name": "Sex",
                "showOtherItem": true,
                "startWithNewLine": false,
                "title": "Sex",
                "type": "dropdown"
              },
              {
                "choices": ["Single", "Twins"],
                "name": "TypeOfBirth",
                "showOtherItem": true,
                "title": "Type Of Birth",
                "type": "dropdown"
              },
              {
                "choices": ["Born Alive", "Born Dead"],
                "isRequired": true,
                "name": "NatureOfBirth",
                "startWithNewLine": false,
                "title": "Nature Of Birth",
                "type": "dropdown"
              }
            ],
            "name": "DetailsOfTheChild",
            "type": "panel"
          },
          {
            "elements": [
              {
                "choices": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
                "name": "Kilograms",
                "title": "Kilograms(kgs)",
                "type": "dropdown"
              },
              {
                "choices": [
                  "100",
                  "200",
                  "300",
                  "400",
                  "500",
                  "600",
                  "700",
                  "800",
                  "900"
                ],
                "name": "Grams",
                "showOtherItem": true,
                "startWithNewLine": false,
                "title": "Grams",
                "type": "dropdown"
              }
            ],
            "name": "WeightOfBirth",
            "title": "Weight Of Birth",
            "type": "panel"
          }
        ],
        "name": "Childs Information",
        "title": "Childs Information"
      },
      {
        "elements": [
          {
            "choices": ["Yes", "No"],
            "description": "(Mandatory)",
            "name": "Isthefathersinformationavailable",
            "title": "Is the father's information available?",
            "type": "dropdown"
          },
          {
            "elements": [
              {
                "choices": [
                  "Adult (Above 18 years)",
                  "Minor (below 18years)",
                  "Not Able to Access Identification Document"
                ],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "CategoryOfFather",
                "title": "Category Of Father",
                "type": "dropdown"
              },
              {
                "choices": ["Citizen", "Foreigner", "Alien"],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "FatherTypeofNationality",
                "title": "Type of Nationality",
                "type": "dropdown",
                "visibleIf":
                "{CategoryOfFather} anyof ['Adult (Above 18 years)', 'Minor (below 18years)']"
              },
              {
                "displayTemplate":
                "<h4 class = \"bg-white text-dark border rounded \n p-3\">\nKENYAN\n<h4>",
                "name": "Nationality",
                "title": "Nationality",
                "type": "genericquestion",
                "visibleIf": "{FatherTypeofNationality} anyof ['Citizen']"
              },
              {
                "description": "(Mandatory)",
                "lookupDataTemplateId": "054353fb-9938-4e63-a7ad-a11c3ac83b5e",
                "lookupServiceId": 2,
                "name": "IPRSLookup",
                "outputs": [
                  {
                    "text": "<<result.id_number>>",
                    "value": "FatherIdentificationNumber"
                  },
                  {"text": "<<result.first_name>>", "value": "FatherFirstName"},
                  {"text": "<<result.other_name>>", "value": "FatherMiddleName"},
                  {"text": "<<result.surname>>", "value": "FatherFathersName"},
                  {"text": "<<result.dob>>", "value": "FatherDateOfBirth"}
                ],
                "title": "IPRS Lookup",
                "type": "httplookup",
                "visibleIf":
                "{FatherTypeofNationality} anyof ['Citizen', 'Alien'] and {CategoryOfFather} anyof ['Adult (Above 18 years)']"
              },
              {
                "description": "ID/Passport Number",
                "enableIf": "{FatherTypeofNationality} anyof ['Foreigner']",
                "name": "FatherIdentificationNumber",
                "title": "Identification Number",
                "type": "text",
                "visibleIf":
                "{FatherTypeofNationality} anyof ['Citizen', 'Alien', 'Foreigner'] and {CategoryOfFather} anyof ['Adult (Above 18 years)']"
              },
              {
                "enableIf":
                "{FatherTypeofNationality} anyof ['Foreigner'] or {CategoryOfFather} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "isRequired": true,
                "name": "FatherFirstName",
                "title": "First Name",
                "type": "text"
              },
              {
                "enableIf":
                "{FatherTypeofNationality} anyof ['Foreigner'] or {CategoryOfFather} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "name": "FatherMiddleName",
                "startWithNewLine": false,
                "title": "Middle Name",
                "type": "text"
              },
              {
                "enableIf":
                "{FatherTypeofNationality} anyof ['Foreigner'] or {CategoryOfFather} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "name": "FatherFathersName",
                "readOnly": true,
                "startWithNewLine": false,
                "title": "Father's Name",
                "type": "text"
              },
              {
                "choicesByUrl": {
                  "titleName": "text",
                  "url":
                  "https://crs.pesaflow.com/resources/download/nationality",
                  "valueName": "value"
                },
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "FatherNationality",
                "renderAs": "select2",
                "title": "Nationality",
                "type": "dropdown",
                "visibleIf":
                "{FatherTypeofNationality} anyof ['Foreigner', 'Alien']"
              },
              {
                "maxErrorText": "Invalid format 12 digits e.g +254700000000",
                "minErrorText": "Invalid format 12 digits e.g +254700000000",
                "name": "fatherMobileNumber",
                "placeholder": "+254720217295",
                "requiredErrorText": "Invalid format 12 digits e.g +254700000000",
                "title": "Mobile Number",
                "type": "text",
                "validators": [
                  {
                    "regex": "^[+][0-9]{12}\$",
                    "text": "Invalid format 12 digits e.g +254700000000",
                    "type": "regex"
                  }
                ]
              },
              {
                "name": "fatherEmail",
                "placeholder": "abc@yxz.com",
                "startWithNewLine": false,
                "title": "Email",
                "type": "text"
              },
              {
                "isRequired": true,
                "name": "fatherBioData",
                "storeDataAsText": false,
                "title": "Attach Bio-Data Page",
                "type": "file",
                "visibleIf": "{FatherTypeofNationality} anyof ['Foreigner']"
              }
            ],
            "name": "Fathers",
            "startWithNewLine": false,
            "title": "Father's",
            "type": "panel",
            "visibleIf":
            "{Isthefathersinformationavailable} = 'Yes' and {MotherMaritalStatus} anyof ['Married', 'Divorced', 'Widowed']"
          }
        ],
        "name": "Father's Information",
        "title": "Father's Information",
        "visibleIf":
        "{MotherMaritalStatus} anyof ['Divorced', 'Widowed', 'Married'] and {IsthechildAbandoned} anyof ['NO']"
      },
      {
        "elements": [
          {
            "choices": [
              {
                "value": "Mother",
                "visibleIf": "{CategoryOfMother} anyof ['Adult (Above 18 years)']"
              },
              {
                "enableIf":
                "{MotherMaritalStatus} anyof ['Married', 'Divorced', 'Widowed']",
                "value": "Father",
                "visibleIf": "{FatherIdentificationNumber} notempty"
              },
              "Other"
            ],
            "isRequired": true,
            "name": "informant",
            "title": "Who is the Informant?",
            "type": "radiogroup"
          },
          {
            "elements": [
              {
                "choices": [
                  "Citizen",
                  "Foreigner",
                  "Alien",
                  "Not able to provide Valid Identification Document"
                ],
                "isRequired": true,
                "name": "InformantTypeofNationality",
                "title": "Type of Nationality",
                "type": "dropdown"
              },
              {
                "displayTemplate":
                "<h4 class = \"bg-white text-dark border rounded \n p-3\">\nKENYAN\n<h4>",
                "name": "Nationality",
                "title": "Nationality",
                "type": "genericquestion",
                "visibleIf": "{InformantTypeofNationality} anyof ['Citizen']"
              },
              {
                "lookupDataTemplateId": "054353fb-9938-4e63-a7ad-a11c3ac83b5e",
                "lookupServiceId": 2,
                "name": "InformantLookup",
                "outputs": [
                  {
                    "text": "<<result.id_number>>",
                    "value": "InformantIdentificationNumber"
                  },
                  {
                    "text": "<<result.first_name>>",
                    "value": "InformantFirstName"
                  },
                  {
                    "text": "<<result.other_name>>",
                    "value": "InformantMiddleName"
                  },
                  {"text": "<<result.surname>>", "value": "InformantFathersName"}
                ],
                "title": "Look Up",
                "type": "httplookup",
                "visibleIf":
                "({InformantTypeofNationality} anyof ['Citizen', 'Alien'])"
              },
              {
                "description": "ID/Passport Number",
                "enableIf": "{InformantTypeofNationality} anyof ['Foreigner']",
                "name": "InformantIdentificationNumber",
                "title": "Identification Number",
                "type": "text",
                "visibleIf":
                "{InformantTypeofNationality} anyof ['Citizen', 'Foreigner', 'Alien']"
              },
              {
                "enableIf": "{InformantTypeofNationality} anyof ['Foreigner']",
                "name": "InformantFirstName",
                "title": "First Name",
                "type": "text"
              },
              {
                "enableIf": "{InformantTypeofNationality} anyof ['Foreigner']",
                "name": "InformantMiddleName",
                "startWithNewLine": false,
                "title": "Middle Name",
                "type": "text"
              },
              {
                "enableIf": "{InformantTypeofNationality} anyof ['Foreigner']",
                "name": "InformantFathersName",
                "startWithNewLine": false,
                "title": "Informant Father's Name",
                "type": "text"
              },
              {
                "choicesByUrl": {
                  "titleName": "text",
                  "url":
                  "https://crs.pesaflow.com/resources/download/nationality",
                  "valueName": "value"
                },
                "name": "InformantNationality",
                "renderAs": "select2",
                "title": "Nationality",
                "type": "dropdown",
                "visibleIf":
                "{InformantTypeofNationality} anyof ['Foreigner', 'Alien']"
              },
              {
                "choices": ["Male", "Female"],
                "name": "InformantGender",
                "title": "Gender",
                "type": "dropdown",
                "visible": false
              },
              {
                "name": "informantMobileNumber",
                "title": "Mobile Number",
                "type": "text"
              },
              {
                "name": "informantEmail",
                "startWithNewLine": false,
                "title": "Email",
                "type": "text"
              },
              {
                "isRequired": true,
                "name": "Capacity",
                "placeholder": "eg Aunt",
                "title": "Capacity",
                "type": "text"
              },
              {
                "acceptedTypes": ".pdf",
                "description": "(PDF)",
                "isRequired": true,
                "name": "informantBioDataPage",
                "storeDataAsText": false,
                "title": "Bio-Data Page",
                "type": "file",
                "visibleIf": "{InformantTypeofNationality} anyof ['Foreigner']"
              }
            ],
            "name": "PanelInformant",
            "startWithNewLine": false,
            "title": "Informant",
            "type": "panel",
            "visibleIf": "{informant} anyof ['Other']"
          },
          {
            "elements": [
              {
                "choices": [
                  "I certify that to the best of my knowledge that the information given in this form is correct."
                ],
                "isRequired": true,
                "name": "Declaration",
                "title": "Informant's Declaration",
                "type": "checkbox"
              },
              {
                "choices": [
                  "Online Signature",
                  "Manual Signature (Download B1, Sign and Upload)",
                  "Upload image of signature (Photo of signature on a plain  white background)"
                ],
                "isRequired": true,
                "name": "typeOfSignature",
                "title": "Type of Signature ",
                "type": "dropdown",
                "visibleIf": "{Declaration} notempty"
              },
              {
                "isRequired": true,
                "name": "signaturePad",
                "title": "Signature Pad",
                "type": "signaturepad",
                "visibleIf": "{typeOfSignature} anyof ['Online Signature']"
              },
              {
                "name": "PhotoofSignatureofInformantonclearbackground",
                "storeDataAsText": false,
                "title": "Photo of Signature of Informant on clear background",
                "type": "file",
                "visibleIf":
                "{typeOfSignature} anyof ['Upload image of signature (Photo of signature on a plain  white background)']"
              }
            ],
            "name": "panel2",
            "type": "panel",
            "visibleIf": "{informant} notempty"
          }
        ],
        "name": "Informant Information",
        "title": "Informant Information"
      },
      {
        "elements": [
          {
            "elements": [
              {
                "html":
                "<a href=\"/applications/{applicationId}/downloads/b1\"target=\"_blank\">CLICK HERE TO DOWNLOAD THE REGISTRATION FORM<BR></a>",
                "name": "question1",
                "type": "html"
              },
              {
                "description": "Please upload the signed B1 form. ",
                "isRequired": true,
                "name": "b1",
                "startWithNewLine": false,
                "storeDataAsText": false,
                "title": "Registration Form B1",
                "type": "file",
                "visibleIf":
                "{typeOfSignature} anyof ['Manual Signature (Download B1, Sign and Upload)']"
              }
            ],
            "name": "panel3",
            "type": "panel"
          },
          {
            "choices": [
              "I certify that to the best of my knowledge that the information given in this form is correct."
            ],
            "name": "RegistrationAssistantsDeclaration",
            "title": "Registration Assistants Declaration",
            "type": "checkbox"
          }
        ],
        "name": "Document Preview",
        "title": "Document Preview"
      }
    ],
    "progressBarType": "buttons",
    "showProgressBar": "top",
    "showQuestionNumbers": "off"
  };
}