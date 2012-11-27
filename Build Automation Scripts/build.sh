#!/bin/sh
# List of Variables used 

DIRECTORY_NAME="ServiceMaxMobile";
SVN_TRUNK_PATH="https://subversion.assembla.com/svn/servicemax-ipad-r4b2/trunk";
BRANCH_NAME="SVMXiPadMobile9.5";
#BRANCH_NAME="SVMXiPadMobileLogger";
TARGET="iService";
APP_NAME="ServiceMax Mobile";
SVN_PATH="$SVN_TRUNK_PATH/$BRANCH_NAME";
LOCAL_PROJECT_PATH=$HOME/$DIRECTORY_NAME;
BUILD_PATH="$LOCAL_PROJECT_PATH/build/Release-iphoneos";
IPA_NAME="ServiceMaxMobile";
API_TOKEN='b696bd3020fac378f3e63d0bf2f9e0a7_NzQ2ODA0MjAxMi0xMS0yMSAwNDowNDoyMS43NTcyNzI';
TEAM_TOKEN='0a910bbc4c645e144c30747f6e107e43_OTYzNzUyMDEyLTA2LTA0IDAyOjAwOjQ5LjE5OTg4Mg';
BUILD_NOTES='This build was uploaded via the upload API';
NOTIFY_TEST_FLIGHT_USERS='True';
DISTRIBUTION_LIST='TestDistribution';

# Method Definitions

# Test Whether the Assembla is Reachable or Not
function check_assembla()
{
	ping -t 1 www.assembla.com > /dev/null;
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
	/usr/bin/xcodebuild -project "$LOCAL_PROJECT_PATH/$TARGET.xcodeproj" -target $TARGET -configuration "Release" CODE_SIGN_IDENTITY='iPhone Distribution: ServiceMax Inc'  clean build
	#/usr/bin/xcodebuild -project "$LOCAL_PROJECT_PATH/SVMXiPadMobileLogger.xcodeproj" -target "SVMXiPadMobileLogger" -configuration "Release" CODE_SIGN_IDENTITY='iPhone Distribution: ServiceMax Inc'  	clean build
	if [ $? -ne 0 ]
	then
		echo "Source Code Not Compiled.";
		exit 1;
	else
		echo "Source Compiled Successfully";
	fi
}

function create_ipa()
{		
	#/usr/bin/zip -rqy "$LOCAL_PROJECT_PATH/$IPA_NAME.ipa" $BUILD_PATH/$APP_NAME.app
	/usr/bin/xcrun -sdk iphoneos PackageApplication "$BUILD_PATH/$APP_NAME.app" -o "$LOCAL_PROJECT_PATH/$APP_NAME.ipa"
	if [ $? -ne 0 ]
	then
		echo "Unable to Create ipa file.";
		exit 1;
	else
		echo "Successfully Create $APP_NAME.ipa";
	fi

	#/usr/bin/xcrun -sdk iphoneos PackageApplication "$BUILD_PATH/$APP_NAME.app" -o "$LOCAL_PROJECT_PATH/$APP_NAME.ipa"
}

function upload_to_testFlight()
{		

curl http://testflightapp.com/api/builds.json -F file=@"$LOCAL_PROJECT_PATH/$APP_NAME.ipa" -F api_token="$API_TOKEN"  -F team_token="$TEAM_TOKEN" -F notes="$BUILD_NOTES" -F notify="$NOTIFY_TEST_FLIGHT_USERS" -F distribution_lists="$DISTRIBUTION_LIST";

	if [ $? -ne 0 ]
	then
		echo "Unable to upload the build to TestFlight.";
		exit 1;
	else
		echo "Successfully uploaded the build to Test Flight";
	fi

}
echo "Checking Assembla Reachability …..";
check_assembla;
echo "Checking for the old project $DIRECTORY_NAME ..";
remove_old_project;
echo "Checking out the latest source code ..";
check_out_latest_source_code;
echo "Building the Project";
do_build;
echo "Creating ipa file";
create_ipa;
echo "Uploading Build to TestFlight ";
upload_to_testFlight;