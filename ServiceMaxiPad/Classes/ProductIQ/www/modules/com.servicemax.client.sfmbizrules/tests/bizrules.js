var bizrules = null;
QUnit.module("BusinessRuleValidator", {
    setup: function() {
        //initialize code
        bizrules = SVMX.create("com.servicemax.client.sfmbizrules.impl.BusinessRuleValidator");
    },
    teardown: function() {
        //cleanup code
        bizrules = null;
    }
});                         

/*
 * batch test based on Michael's sample
 */ 
test("Batch Validation", function(){   
    var rules = {
        header: {
            rules: []
        },
        sampleDetails: {
            rules: []
        }
    };    
    var dataToValidate = {
        datetime1: null,
        datetime2: "",
        datetime3: "2013-05-14T05:52:56.000+0000",
        datetime4: "2013-05-30 02:00:00",
        date1: null,
        date2: "",
        date3: "2013-05-30",
        boolean1: null,
        boolean2: true,
        boolean3: "true",
        boolean4: false,
        boolean5: "false",
        string1: null,
        string2: "",
        string3: "hello world",
        textarea1: null,
        textarea2: "hello world",
        email1: null,
        email2: "michael.kantor@servicemax.com",
        int1: null,
        int2: 55,
        int3: "55",
        double1: null,
        double2: 1.2345,
        double3: "1.2345",
        currency1: null,
        currency2: 35.6789,
        currency3: "35.6789",
        percent1: null,
        percent2: 0.05,
        percent3: "0.05",
        reference1: null,
        reference2: "abcdefg",
        reference3: {
            key: "abcdefg",
            value: "hello world"
        }, // currently doesn't handle these; this is not an acceptable input
        picklist1: null,
        picklist2: "hello world",
        picklist3: {
            key: "hello world",
            value: "hello world"
        }, // currently doesn't handle these; this is not an acceptable input
        multipicklist1: null,
        multipicklist2: "hello",
        multipicklist3: "hello;world",
        "details": {
            "sampleDetails": {
                "lines": [{
                    int1: null,
                    int2: 100,
                    string1: "100"
                }, {
                    int1: 100,
                    int2: null,
                    string1: "hello world"

                }]
            }
        }
    };

    /* While fields is not required, it encodes knowledge of how to compare specific field types, especially Dates.
     * It also helps insure numeric values are compared as numbers rather than strings.
     */
    var fields = {
        "sampleHeaderType": {
            datetime1: "datetime",
            datetime2: "datetime",
            datetime3: "datetime",
            datetime4: "datetime",
            date1: "date",
            date2: "date",
            date3: "date",
            boolean1: "boolean",
            boolean2: "boolean",
            boolean3: "boolean",
            boolean4: "boolean",
            boolean5: "boolean",
            string1: "string",
            string2: "string",
            textarea1: "textarea",
            textarea2: "textarea",
            email1: "email",
            email2: "email",
            int1: "int",
            int2: "int",
            int3: "int",
            double1: "double",
            double2: "double",
            double3: "double",
            currency1: "currency",
            currency2: "currency",
            currency3: "currency",
            percent1: "percent",
            percent2: "percent",
            percent3: "percent",
            reference1: "reference",
            reference2: "reference",
            reference3: "reference",
            picklist1: "picklist",
            picklist2: "picklist",
            picklist3: "picklist",
            multipicklist1: "multipicklist",
            multipicklist2: "multipicklist",
            multipicklist3: "multipicklist"
        },
        "sampleDetails": {
            int1: "int",
            int2: "int",
            string1: "string"
        }
    };
    
    /*
     * build the biz rules data
     */              
    function buildRules(){
        var textOperations = ["eq", "ne", "gt", "ge", "lt", "le", "isnull", "isnotnull", "starts", "contains", "notcontain"];
        var valueOperations = ["eq", "ne", "gt", "ge", "lt", "le", "isnull", "isnotnull"];
        var operations = {
            int: valueOperations,
            double: valueOperations,
            currency: valueOperations,
            percent: valueOperations,
            datetime: valueOperations,
            date: valueOperations,
            boolean: ["eq", "ne", "isnull", "isnotnull"],
            string: textOperations,
            email: textOperations,
            textarea: textOperations,
            reference: textOperations,
            picklist: textOperations,
            multipicklist: ["in", "notin"]
        };  
        var constants = {
            date: ["Now", "Today", "Tomorrow", "Yesterday"],
            datetime: ["Now", "Today", "Tomorrow", "Yesterday"]
        };
        var sampleValues = {
            int: [null, 88, "88"],
            double: [null, 88.88, "88.88"],
            currency: [null, 88.88, "99.99"],
            percent: [null, 88.88, "88.88"],
            datetime: [null, "", "2013-05-14T05:52:56.000+0000", "2013-05-30 02:00:00", "2013-05-30"],
            date: [null, "", "2013-05-30", "2013-05-30 02:00:00"],
            boolean: [null, true, "true", false, "false"],
            string: [null, "", "hello world", "hello world 2"],
            textarea: [null, "hello world", "hello world 3"],
            email: [null, "michael.kantor@servicemax.com", "fred@gmail.com"],
            reference: [null, "abcdefg"],
            picklist: [null, "hello world", "hello world 4"],
            multipicklist: [null, "hello"]
        };
        var completions = {};
        
        for (var fieldName in fields.sampleHeaderType) {
            var fieldType = fields.sampleHeaderType[fieldName];
            SVMX.array.forEach(operations[fieldType], function(inOperation) {
                SVMX.array.forEach(sampleValues[fieldType], function(inOperand) {
                    if (completions[fieldName + "." + inOperation + "." + inOperand]) return;
                    completions[fieldName + "." + inOperation + "." + inOperand + "." + (typeof inOperand)] = true;
                    rules.header.rules.push({
                        ruleInfo: {
                            bizRuleDetails: [{
                                SVMXC__Operand__c: inOperand,
                                SVMXC__Parameter_Type__c: "Value",
                                SVMXC__Operator__c: inOperation,
                                SVMXC__Field_Name__c: fieldName
                            }],
                            bizRule: {
                                SVMXC__Source_Object_Name__c: "sampleHeaderType",
                                SVMXC__Advance_Expression__c: "",
                                SVMXC__Message_Type__c: "WARNING"
                            }
                        },
                        message: "Test [{{" + fieldName + "}}] " + [inOperation] + " [" + inOperand + "] is true; this data is invalid"
                    });
                });
                if (constants[fieldType]) {
                    SVMX.array.forEach(constants[fieldType], function(inOperand) {
    
                        rules.header.rules.push({
                            ruleInfo: {
                                bizRuleDetails: [{
                                    SVMXC__Operand__c: inOperand,
                                    SVMXC__Parameter_Type__c: "Constant",
                                    SVMXC__Operator__c: inOperation,
                                    SVMXC__Field_Name__c: fieldName
                                }],
                                bizRule: {
                                    SVMXC__Source_Object_Name__c: "sampleHeaderType",
                                    SVMXC__Advance_Expression__c: "",
                                    SVMXC__Message_Type__c: "WARNING"
                                }
                            },
                            message: "Test [{{" + fieldName + "}}] " + [inOperation] + " [" + inOperand + "] is true; this data is invalid"
                        });
                    });
                }
            });
        }
    };
    
    //1)
    buildRules();
    
    //2 create asserts
    var params = {
        rules: {
            header: {
                rules: []
            },
            sampleDetails: {
                rules: []
            }
        },
        data: dataToValidate,
        fields: fields
    };
    
    $.each(rules.header.rules, function(id, rule) {
        params.rules.header.rules = [rule];
        var results = bizrules.evaluateBusinessRules(params);  
        
        //build simple assert test 
        var bool = (!results.errors.length) ? 
            ((!results.warnings.length) ? true: false)
            :false;
            
        var message = (!results.warnings.length) ? rule.message: results.warnings[0].message;
        
        equal(bool, true, message);     
    }); 
});


