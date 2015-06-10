---------------------------------------------------------------
-- en.lua
--
-- Localization for en
---------------------------------------------------------------

-- Local Constant Setting
local LOCAL_SETTINGS = {
						RES_DIR = "",					-- Common resource directory for scene
						DOC_DIR = "",					-- Common document directory for scene
						}

---------------------------------------------------------------
-- Require Parts
---------------------------------------------------------------

---------------------------------------------------------------
-- Constants
---------------------------------------------------------------

---------------------------------------------------------------
-- Variables
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions Prototype
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------
return {
			name = "English",
			list = {
					-- Main Tab
					notice = "Notice",
					post = "Post",
					me = "Me",
					setting = "Setting",
					------- main vorum scene
					vorum_global = "Global",
					vorum_myCountry = "My Country",
					------- login page scene
					login_forgetPassword = "Forget password",
					login_signIn = "Sign in",
					login_createAccount = "Create Account",
					login_loginWithFacebook = "Login with Facebook",
					login_username_textField_placeholder = "Email",
					login_password_textField_placeholder = "Password",
					login_loginExpired = "Login Expired",
					login_loginExpiredPleaseLoginAgain = "Your login is expired. Please login again",
					
					------- register scene
					register_username_textField_placeholder = "Username",
					register_password_textField_placeholder = "Password",
					register_comfirmPassword_textField_placeholder = "Confirmed password",
					register_account = "Account",
					register_name_textField_placeholder = "Name",
					register_birth_textField_placeholder = "Date of birth (DD/MM/YYYY)",
					register_profile = "Profile",
					register_email_textField_placeholder = "Email",
					register_male = "Male",
					register_female = "Female",
					register_iagree = "I agree",
					register_terms_and_conditions = " terms and conditions.",
					register_confirm = "Confirm",
					------- edit personal data scene
					edit_update = "Update",
					edit_updateInfo = "Update Info",
					edit_setupMyCountry = "Set up my country.",
					
					------- me tab
					meTab_title = "Me",
					meTab_myPost = "My post",
					meTab_voted = "Voted",
					meTab_friends = "Friends",
					------- post scene
					post_headerTitle = "POST",
					post_headerRightButton = "Next",
					post_question = "Question",
					post_title = "Title",
					post_description = "Description",
					post_linkToSite = "Link to site",
					post_title_desc = "It is optional to add photo on question.",
					post_linkToSite_desc = "You may add a link as an additional information.",
					post_attention = "Must be filled.", 
					post_back = "< Back",
					post_quit = "Quit",

					------- post scene2
					post2_choices = "Choices",
					post2_description = "Maximum 30 characters.",
					post2_textField_placeholder = "Title",
					------- post scene3
					post3_audience = "Audience",
					post3_headerRightButton = "Post",
					post3_tag = "Tag",
					post3_public = "Public",
					post3_friendsOnly = "Friends only",
					post3_select_tag = "Please select a tag",
					post3_tag_description = "Your user name will not be displayed when you selected 'anonymous'.",
					post3_VIP = "VIP",
					post3_coupon = "Coupon",
					post3_title = "Title",
					post3_hideResult = "Hide Result",
					post3_done = "Done",
					post3_cancel = "Cancel",
				
					------- notice scene
					notice_headerTitle = "Notification",

					notice_action_postVoted = "Your post \"",
					notice_action_postVoted2 = "\" has been voted.",
					notice_action_postShare = " shared your post.",
					notice_action_postExpired = "Your post \"",
					notice_action_postExpired2 = "\" expired.",
					notice_action_addFriend = " added you as a friend.",
					notice_action_acceptFriend = " accepted you as friend.",
					notice_action_newCoupon = "You own a new coupon from ",
					notice_action_newCoupon2 = ".",
					------- setting scene
					setting_headerTitle = "Setting",
					setting_edit_button = "Edit",
					
					setting_tutorial = "Tutorial",
					setting_redemption = "Redemption",
					setting_aboutVorum = "About Vorum",
					setting_contact = "Contact",
					setting_signOut = "Sign Out",
					--
					relationship_addFriend_button = "Add Friend",
					relationship_unfriend_button = "Unfriend",
					relationship_pending_button = "Pending",
					relationship_approval_button = "Approval",
					relationship_reject_button = "Reject",
					------ setting scene > contact scene
					contact_headerTitle = "Contact",
					contact_partnership = "Partnership",
					contact_content = "What if your company want to join our partnership to settle a promotion, please feel free to contact us.",
					contact_phoneTo = "Call %s?",
					------ setting scene > tutorial scene
					tutorial_skip = "Skip",
					------ setting scene > redemption scene
					redemption_headerTitle = "Redemption",
					redemption_noCoupon = "No Coupon",
					redemption_MoreThan1Day = "More than 1 day",
					redemption_Invalid = "Invalid",
					redemption_Remain = "Remain ",
					redemption_Hour = " Hour ",
					redemption_Min = " Min ",
					redemption_Sec = " Sec",
					------ setting scene > redemption scene > coupon scene
					coupon_headerTitle = "Coupon",
					------ setting scene > about vorum scene
					aboutVorum_headerTitle = "About Vorum",
					-- aboutVorum_appIntro = "Vorum is a voting forum. Opinions are gathered to generate meaning insight.",
					-- aboutVorum_appDesc = "Vorum is the 1st ever profit sharing mobile app. Any users can get a chance to share the profit from the sale of meaning insight.",
					-- aboutVorum_contactWay = "Find out more on:",
					-- aboutVorum_facebookContact = "Facebook: ",
					-- aboutVorum_emailContact = "Email: ",
					-- aboutVorum_websiteContact  = "Website: ",
					aboutVorumDesc1 = {
										"Vorum - a voting forum with minimal words",
										"We show picture and choices without overwhelming messages. It is easy to read and understand.",
										"Vorum - a platform that gathers user's thoughts",
										"Any users can easily make a change to this world by gathering people's thoughts",
										"Vorum - a profit sharing mobile application",
										"User's participation is the key to the success of our business. As we recognise user's contribution, we created a profit sharing mechanism in our business model.",
										"Check out our URL:",
										},
					aboutVorumDesc2 = {
										"to find out more how you can make a difference to this world or the opportunity to make extra money.",
										"Contact us at email:",
									},
					------ profile scene
					profile_unfriend = "Unfriend",
					------ cat screen
					cat_headerTitle = "Category",
					cat_headerLeftButton = "Back",
					cat_headerRightButton = "Done",
					cat_tag = "TAG",
					cat_latest = "Latest",
					cat_mostVoted = "Most",
					cat_mostVoted_all = "All",
					cat_mostVoted_week = "1W",
					cat_mostVoted_month = "1M",
					cat_all = "All",
					cat_30mins = "30mins",
					cat_anonymous = "Anonymous",
					cat_appraisal = "Appraisal",
					cat_general = "General",
					-- cat_shopping = "Shopping",
					-- cat_news = "News",
					-- cat_sport = "Sport",
					-- cat_food = "Food",
					-- cat_entertainment = "Entertainment",
					-- cat_games = "Games",
					-- cat_fashionAndBeauty = "Fashion and beauty",
					-- cat_digital = "Digital",
					-- cat_love = "Love",
					-- cat_others = "Others",
					
					------ search screen
					search_post = "Post",
					search_people = "People",
					search_post_noResult = "No result",
					search_people_noResult = "No result",
					---------- function
					--addPhoto
					addPhoto_takePhoto = "Camera",
					addPhoto_pickPhoto = "Gallery",
					addPhoto_deletePhoto = "Delete",
					addPhoto_cancel = "Cancel",
					--postButton
					postButton_push = "Push",
					postButton_report = "Report",
					postButton_share = "Share",
					postButton_shareToWhatsapp = "Share to whatsapp",
					postButton_shareToFacebook = "Share to Facebook",
					postButton_shareToMyWall = "Share to my wall",
					postButton_delete = "Delete",
					postButton_cancel = "Cancel",

					--login error
					loginError_errorTitle = "Login Error",
					loginError_emptyUsername = "Your username cannot be empty.",
					loginError_emptyPassword = "Your password cannot be empty.",
					loginError_wrongData = "Your username or password is wrong.",
					loginError_emailNoAt = "Please ensure the email correct.",
					loginError_emailNoVerified = "Your email is still not verified. Resend verification email?",
					--register success
					registerSuccess_registerTitle = "Register success",
					registerSuccess_register = "You will receive a email. Please verify your account through email then login.",
					resendVerificationEmail = "Verification email has been sent.",
					--register fail
					registerFail_registerTitle = "Register Fail",
					registerFail_invalidEmail = "Invalid email address",
					registerFail_emailAlreadyRegistered = "Email address had already registered.",
					registerFail_ErrorOccurred = "Error Code: %s, Message: %s",

					--update userData success
					updateUserDataSuccess_updateTitle = "Update success",
					updateUserDataSuccess_update = "Update user Data success",
					--network error
					networkError_errorTitle = "Network Error",
					networkError_networkError = "Cannot connect network, please check the network.",

					--4 button(push,report,share,delete) error
					pushPostError_pushedAlreadyTitle = "Push Error",
					pushPostError_pushedAlreadyDesc = "Today you already pushed this post.",
					reportPostError_reportAlreadyTitle = "Report Error",
					reportPostError_reportAlreadyDesc = "Today you already report this post.",
					
					--4 button(push,report,share,delete) success
					pushPostSuccessTitle = "successfully Pushed",
					reportPostSuccessTitle = "Successfully Reported",
					sharePostSuccessTitle = "Successfully Shared",
					deletePostSuccessTitle = "delete successfully",
					
					pushPostSuccess = "The post now become the top post in \"Latest\" category.",
					reportPostSuccess = "Thanks for the feedback. Our team will review your report shortly.",
					sharePostSuccess = "The post has been shared to your own wall.",
					deletePostSuccess = "Delete post successfully.",
					--create post and new coupon success
					newPostSuccessTitle = "Create a new post successfully",
					newCouponSuccessTitle = "Create new post and coupon successfully",
					newPostSuccess = "Create a new post successfully.",
					newCouponSuccess = "Create new post and coupon successfully.",
					--create new post error
					networkError_newPost = "Network error, post don't create." ,
					networkError_newCoupon = "Network error, coupon don't create.",
					--necessary input
					necessaryInput_title = "Some fields must be filled",
					necessaryInput_post1Title = "Title must be filed",
					necessaryInput_post2ChoiceA = "At least 2 choices have to be given.",
					necessaryInput_post2ChoiceB = "At least 2 choices have to be given.",
					necessaryInput_post2FillChoiceDEmptyChoiceC = "You must fill choice C and then fill choice D.",
					--input check
					inputCheck_title = "Input characters excesses limitation.",
					inputCheck_passwordDiffTitle = "Password and confirmed password must be the same.",
					inputCheck_passwordDiff = "Password and confirmed password must be the same.",
					inputCheck_mustFillTitle = "Some fields must be filled.",
					inputCheck_fillEmail = "Email must be filed.",
					inputCheck_fillPassword = "Password must be filed.",
					inputCheck_fillConfirmedPassword = "Confirmed password must be filed.",
					inputCheck_fillName = "Name must be filed.",
					inputCheck_emailNoAtTitle = "Wrong email address",
					inputCheck_emailNoAt = "Please ensure the email correct.",
					inputCheck_chooseGender = "You must choose a gender.",
					inputCheck_agreeCheckBoxTitle = "The terms and conitions",
					inputCheck_agreeCheckBox = "Yuu must agree the terms and conditions.",
					inputQuestion_limited = "Question input limited to 30 characters.",
					inputDesc_limited = "Description input limited to 100 characters.",
					inputPost2Desc_limited = "Description input limited to 30 characters.",
					inputCouponTitle_limited = "Coupon description input limited to 200 characters.",

					post3CouponDataNotEnoughTitle = "Coupon data is not enough",
					post3CouponDataNotEnough = "You must include text and photo for the coupon.",
					post3InputCheckTitle = "No coupon",
					post3InputCheck_noCouponHideResult = "You must have a coupon.",
					--register GPS
					GPS_openGpsTitle = "Please open your GPS.",
					GPS_openGps = "You cannot use \"My Country\" function if you do not enable GPS. Do you still want to register?",
					GPS_openGpsOption_open = "Cancel",
					GPS_openGpsOption_continue = "Continue",
					--birthday error
					birthdayError_title = "Birthday error",
					birthdayError_noThatDay = "This month had no this day.",
					birthdayError_overNow = "Birthday error.",
					redemption_noCoupon = "No Coupon",
					--personal part
					personalInfo_voted = " voted",
					personalInfo_posts = " posts",
					
					--facebook choice
					ok = "OK",
					cancel = "Cancel",
					retry = "Retry",

					-- Facebook Login Procedure
					fb_inputLoginData = "Please input data",
					fb_inputLoginDataToLink = "Please input the login data below",
					fb_noFbAcc = "Cannot find account",
					fb_noFbAcc_Create = "Cannot find an account linked with Facebook. Create new account or Link the existing account?",
					create = "Create",
					link = "Link",
					fb_createAcc = "Create account",
					fb_createNewAcc = "Create new account?",
					fb_linkToAcc = "Link to account",
					fb_linkFbToAcc = "Link the Facebook account to existing account?",
					fb_cantLoginAccToLink = "Cannot login to Account",
					fb_accountLinked = "Account linked",
					fb_accountLinkedSuccessfully = "The Facebook account is linked to existing Vorum account successfully",
					fb_cannotRetrieveFacebookData = "Cannot Retrieve Facebook Data",
					fb_cantLoginAccToLink_Retry = "Cannot login to Account. Retry?",
					fb_notVerifiedAccToLink_Retry = "The account is not verified so cannot link. Retry another?",
					fb_accAlreadyLinked_Retry = "The account is already linked with another Facebook account. Retry another?",
					yes = "Yes",
					no = "No",


					-- Post
					anonymous = "Anonymous",
					justNow = "Just Now",
					minAgo = " Min Ago",
					minsAgo = " Mins Ago",
					hourAgo = " Hour Ago",
					hoursAgo = " Hours Ago",
					-- those are not use in "en"
					createAtYear = " year ",
					createAtMonth = " month ",
					createAtDay = " day ",
					post_MyPost = "My Post",
					post_Rewards = "Rewards",
					view = " view",
					views = " views",
					voted = " voted",
					expireTime_MoreThan30Mins = "> 30 Mins",
					expireTime_Expired = "Expired",
					expireTime_Remain = "Remain ",
					post_PleaseGoToSettingRedemptionToSeeCoupon = "Please go to Setting > Redemption to get the coupon",
					post_ClickHereToGoToRedemptionPage = "Click here to go to redemption page to get the coupon",
					post_Result = "RESULT",
					post_noVote = "No Vote",
					post_same = "Same",
					post_maleLetter = "M",
					post_femaleLetter = "F",
					post_updatingResult = "Updating Result...",
					post_deleting = "Deleting...",
					postDoesNotExist = "The post does not exist.",

					-- voting
					alreadyVotePost = "You are already voted the post",
					
					--register>termAndConitions
					termsAndConitions_title = "Terms and conditions",

					sharePostSentence1 = "Vorum has a new post!",
					sharePostSentence2 = "Click the link to download the app and Vote!",

					-- friend request
					friendRequest_alreadyRequest = "You are already requested as friend.",
					friendRequest_alreadyRequest_cancel = "You are already requested as friend. Cancel?",

					--forgetPassword
					forgetPasswordErrorTitle_noEmail = "Wrong email",
					forgetPasswordErrorDesc_noEmail = "This email is still not registered. Please check your email spelling.",
					forgetPasswordSuccessTitle = "Reset password email sent",
					forgetPasswordSuccessDesc = "Please check you email to reset password.",
					--
					noPost = "No post",
					noNotic = "No notification",
					--facebook share
					facebookShareSuccessTitle = "Share successfully",
					facebookShareSuccessDesc = "Share to Facebook successfully.",
					facebookShareErrorTitle = "Share error",
					facebookShareErrorDesc = "Share to Facebook unsuccessfully.",

					--notice is not work
					noticeNotWorkTitle = "Notification",
					noticeNotWorkDesc = "Notification is not opened now.",


					--4 button(push,report,share,delete) failed
					pushPostFailedTitle = "Push failed",
					reportPostFailedTitle = "report failed",
					sharePostFailedTitle = "share failed",
					deletePostFailedTitle = "delete failed",
					
					pushPostFailedDesc = "Push post failed.",
					reportPostFailedDesc = "Report post failed.",
					sharePostFailedDesc = "Share post failed.",
					deletePostFailedDesc = "Delete post failed.",

					deletePostConfirmTitle = "Do you want to delete post?",
					deletePostConfirmDesc = "If yes, your post will terminate permanently.",
					--
					unknownErrorTitle = "Unknown error",
					unknownErrorDesc = "Unknown error",

					forgetPassword_popupInput = "Please input your email.",
					-- Tag
					Appraisal = "Appraisal",
					Anonymous = "Anonymous",
					General = "General",
					["30mins"] = "30 Mins",
					All = "All",
					helloString = "Hello",
					listString = {
									"Row 1",
									"Row 2",
									"Row 3",
									},
					},
		}
