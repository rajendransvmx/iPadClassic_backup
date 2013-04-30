#!/bin/sh
# List of Variables used 


DIRECTORY_NAME="ServiceMaxMobile";
SVN_TRUNK_PATH="https://subversion.assembla.com/svn/servicemax-ipad-r4b2/trunk";
TARGET="iService";
APP_NAME="ServiceMax Mobile";

## ## ## ## ## ## ## ## ## ## ##
# Dynamic Variables
## ## ## ## ## ## ## ## ## ## ##

BRANCH_NAME="SVMXiPadMobile11.2";
BUILD_NOTES='Hi All,\n Please find release notes for the build 11.0.0.1 \n Sprint :  \n Current Build Version :  \n Next Build Version :  \n Release Notes : \n ========================================== \nDeliverable : -\n D-00002298 : Override SFM Sync With Custom WS';


SVN_PATH="$SVN_TRUNK_PATH/$BRANCH_NAME";
LOCAL_PROJECT_PATH=$HOME/$DIRECTORY_NAME;
BUILD_PATH="$LOCAL_PROJECT_PATH/build/Release-iphoneos";
IPA_NAME="ServiceMaxMobile";

## ## ## ## Profiles and Certificate ## ## ## ##
declare -a CERTIFICATE_DISTRIBUTION;
CERTIFICATE_1_DISTRIBUTION="iPhone Distribution: ServiceMax Inc";
CERTIFICATE_2_DISTRIBUTION="iPhone Distribution: Rajesh Rao";
CERTIFICATE_DISTRIBUTION=("$CERTIFICATE_1_DISTRIBUTION" "$CERTIFICATE_2_DISTRIBUTION");

PROFILE_1_UUID="A4419530-58FB-4B3A-9562-09E8B4133F51";
PROFILE_2_UUID="2702F4CD-124E-4E0A-834B-EB775685AF15";

PROFILE_UUID=("$PROFILE_1_UUID" "$PROFILE_2_UUID");
PROFILE_ALIAS_ARRAY=("All_Devices","Client_Devices");

## ## ## ## Test Filght Varibles## ## ##

API_TOKEN='d271223eaf72ccf86a60a7c1853686c8_NDY5MTI5MjAxMi0wNi0wNCAwMjowNjowNS40NzU4ODQ';
API_TOKEN_ARR=("$API_TOKEN" "$API_TOKEN");
TEAM_1_TOKEN='4ccc1984556c48b6c3cc34d5047f8542_MTY1OTgyMjAxMi0xMi0xMyAwNTowNjozMy42NjgxODE';    
TEAM_2_TOKEN='5f4757d27c2c3a1ce879d12390a91555_MTY3OTY2MjAxMy0wNC0xOCAwMTozNToyMS45NTk4MzA';
TEAM_TOKEN_ARR=("$TEAM_1_TOKEN" "$TEAM_2_TOKEN");
DISTRIBUTION_LIST='TestDistribution'; # Used for sending the mail to the distribution group.
NOTIFY_TEST_FLIGHT_USERS='False'; # Make it as True to send the email


# Method Definitions

# Test Whether the Assembla is Reachable or Not
function check_assembla()
{

ping -t 5 www.assembla.com > /dev/null;

	if [ $? -ne 0 ]
	then
		echo "Assembla Not Reachable.";
		exit 1;
	else
		echo "Assembla is Reachable.";
	fi
}

# See if old project is there. Delete the folder if the folder exists
function remove_old_project()
{
	test -d $LOCAL_PROJECT_PATH;
	if [ $? -ne 0 ]
	then
		echo "$LOCAL_PROJECT_PATH is not available ..";
	else
		echo "Removing Directory $LOCAL_PROJECT_PATH ..";
		rm -rf $LOCAL_PROJECT_PATH;
		if [ $? -ne 0 ]
		then
			echo "Unable to delete the folder $LOCAL_PROJECT_PATH";
			exit 1;
		fi
		
	fi
}

# check out the latest source code from assembla
function check_out_latest_source_code()
{
	echo $SVN_PATH;
	echo "Branch Name $BRANCH_NAME";
	svn co $SVN_PATH $LOCAL_PROJECT_PATH;
	if [ $? -ne 0 ]
	then
		echo "Source Code could't Check-Out Properly.";
		exit 1;
	else
		echo "Successfully Check-out the Source Code";
	fi

}
function do_build()
{
echo "Do Build : $1 $2";
	echo "Local Path $LOCAL_PROJECT_PATH";
echo "Argument 1:" . $1
echo "Argument 2:" . $2
#/usr/bin/xcodebuild -project "$LOCAL_PROJECT_PATH/$TARGET.xcodeproj" -target $TARGET -configuration "Release" -sdk iphoneos CODE_SIGN_IDENTITY="$1" PROVISIONING_PROFILE ="$2" clean build

/usr/bin/xcodebuild -project "$LOCAL_PROJECT_PATH/$TARGET.xcodeproj" -target $TARGET -configuration "Release" -sdk iphoneos CODE_SIGN_IDENTITY="$1"  clean build

	if [ $? -ne 0 ]
	then
		echo "Source Code Not Compiled for $1";
		exit 1;
	else
		echo "Source Compiled Successfully for $2";
	fi
}

function create_ipa()
{
case $3 in

0) PROFILE_UUID=$PROFILE_1_UUID;;
1) PROFILE_UUID=$PROFILE_2_UUID;;
*) echo "Invalid Profile UUID";;
esac

    PROFILE_PATH=$HOME/Library/MobileDevice/Provisioning\ Profiles/$PROFILE_UUID.mobileprovision;
echo "Create Directory with Name : $2";
    cd $LOCAL_PROJECT_PATH;
    mkdir $2;

echo "Profile Path: $PROFILE_PATH";
	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "$BUILD_PATH/$APP_NAME.app" -o "$LOCAL_PROJECT_PATH/$2/$APP_NAME.ipa" --sign "$1" --embed "$PROFILE_PATH"

	if [ $? -ne 0 ]
	then
		echo "Unable to Create ipa file.";
		exit 1;
	else
		echo "Successfully Create $APP_NAME.ipa";
	fi

}

function upload_to_testFlight()
{

TEAM_TOKEN="$1";
API_TOKEN="$3";
echo "TEAM_TOKEN : $TEAM_TOKEN  API Token: $API_TOKEN";
echo "App Path : $LOCAL_PROJECT_PATH/$2/$APP_NAME"
curl http://testflightapp.com/api/builds.json -F file=@"$LOCAL_PROJECT_PATH/$2/$APP_NAME.ipa" -F api_token="$API_TOKEN"  -F team_token="$TEAM_TOKEN" -F notes="$BUILD_NOTES" -F notify="$NOTIFY_TEST_FLIGHT_USERS";

	if [ $? -ne 0 ]
	then
		echo "Unable to upload the build to TestFlight to team $1.";
		exit 1;
	else
		echo "Successfully uploaded the build to Test Flight to team $1 ";
	fi

}
## ## ## ## ## ## ## ## ## ## ## #### ## ## ## ## ## ## ## ## ## ## ##
## ## ## ## ## ## Automation building Script ## ## ## ## ## ##
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
echo "Checking Assembla Reachability …..";
check_assembla ;
echo "Checking for the old project $DIRECTORY_NAME ..";
remove_old_project ;
echo "Checking out the latest source code ..";
check_out_latest_source_code;
echo "No of Builds to be created:${#CERTIFICATE_DISTRIBUTION[@]}";
countOfProfiles=${#CERTIFICATE_DISTRIBUTION[@]};
for (( i=0; i<${countOfProfiles}; i++ ));
do
    echo ${CERTIFICATE_DISTRIBUTION[$i]};
    echo ${PROFILE_UUID[$i]};
case $i in
0) PROFILE_ALIAS="All_Devices";;
1) PROFILE_ALIAS="Client_Devices";;
*) echo "Invalid Selection";;
esac
echo "PROFILE_ALIAS :$PROFILE_ALIAS";
        echo "Call Methods for $i ";
echo " Build the project for profile ${PROFILE_UUID[$i]} with Certificate as ${CERTIFICATE_DISTRIBUTION[$i]}"
do_build "${CERTIFICATE_DISTRIBUTION[$i]}" "${PROFILE_UUID[$i]}";

echo " Create ipa at folder named $PROFILE_ALIAS";

create_ipa "${CERTIFICATE_DISTRIBUTION[$i]}"  "$PROFILE_ALIAS" $i;
done

echo "Uploading Build to TestFlight  ";

NoOfTeams=${#TEAM_TOKEN_ARR[@]};
for (( i=0; i<${NoOfTeams}; i++ ));
do
case $i in
0) FOLDER_NAME="All_Devices";;
1) FOLDER_NAME="Client_Devices";;
*) echo "Invalid Selection";;
esac
echo "Uploading Build to Team Id ${TEAM_TOKEN_ARR[$i]}";
echo "------------------------------ ";
upload_to_testFlight "${TEAM_TOKEN_ARR[$i]}" "$FOLDER_NAME" "${API_TOKEN_ARR[$i]}";
done


