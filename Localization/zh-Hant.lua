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
			name = "繁體中文",
			list = {
					-- Main Tab
					notice = "通知",
					post = "帖子",
					me = "自己",
					setting = "設定",

					------- main vorum scene
					vorum_global = "全球",
					vorum_myCountry = "我的國家",

					------- login page scene
					login_forgetPassword = "忘記密碼",
					login_signIn = "登入",
					login_createAccount = "創建帳戶",
					login_loginWithFacebook = "Facebook登入",
					login_username_textField_placeholder = "電郵地址",
					login_password_textField_placeholder = "密碼",
					login_loginExpired = "登入逾時",
					login_loginExpiredPleaseLoginAgain = "登入逾時。請重新登入。",

					------- register scene
					register_username_textField_placeholder = "帳戶名稱",
					register_password_textField_placeholder = "密碼",
					register_comfirmPassword_textField_placeholder = "確認密碼",
					register_account = "帳戶",
					register_name_textField_placeholder = "名稱",
					register_birth_textField_placeholder = "生日日期 (日/月/年)",
					register_profile = "個人資料",
					register_email_textField_placeholder = "電郵地址",
					register_male = "男",
					register_female = "女",
					register_iagree = "我同意",
					register_terms_and_conditions = "服務條款和私隱政策",
					register_confirm = "確定",

					------- edit personal data scene
					edit_update = "更新資料",
					edit_updateInfo = "更新資料",
					edit_setupMyCountry = "設置我的國家。",

					------- me tab
					meTab_title = "自己",
					meTab_myPost = "我的帖子",
					meTab_voted = "已投票",
					meTab_friends = "朋友",
					------- post scene
					post_headerTitle = "新帖",
					post_headerRightButton = "下一頁",
					post_question = "問題",
					post_title = "標題",
					post_description = "描述",
					post_linkToSite = "連結",
					post_title_desc = "你可以選擇性加入關於問題的相片。",
					post_linkToSite_desc = "你可以加入連結來作為額外資訊。",
					post_attention = "必須輸入", 
					post_back = "< 後退",
					post_quit = "離開",

					------- post scene2
					post2_choices = "選項",
					post2_description = "最大30個字符。",
					post2_textField_placeholder = "標題",
					------- post scene3
					post3_audience = "觀眾",
					post3_headerRightButton = "開新帖子",
					post3_tag = "標籤",
					post3_public = "公開",
					post3_friendsOnly = "只限朋友",
					post3_select_tag = "請選擇一個標籤",
					post3_tag_description = "你的名稱將不會顯示在帖子上，如果你選擇'匿名'",
					post3_VIP = "會員",
					post3_coupon = "優惠卷",
					post3_title = "標題",
					post3_hideResult = "隱藏結果",
					post3_done = "完成",
					post3_cancel = "取消",
				
					------- notice scene
					notice_headerTitle = "通知",
					
					notice_action_postVoted = "有人投了你的帖子",
					notice_action_postVoted2 = "。",
					notice_action_postShare = " 分享你的帖子。",
					notice_action_postExpired = "你的帖子\"",
					notice_action_postExpired2 = "\"已經停止投票。",
					notice_action_addFriend = " 邀請你作為朋友。",
					notice_action_acceptFriend = " 接受你作為朋友。",
					notice_action_newCoupon = "你取得一個來自",
					notice_action_newCoupon2 = "的優惠卷。",
					------- setting scene
					setting_headerTitle = "設定",
					setting_edit_button = "修改",
					
					setting_tutorial = "教學",
					setting_redemption = "優惠卷",
					setting_aboutVorum = "關於Vorum",
					setting_contact = "聯絡我們",
					setting_signOut = "登出",
					--
					relationship_addFriend_button = "加為朋友",
					relationship_unfriend_button = "移除好友",
					relationship_pending_button = "請求中",
					relationship_approval_button = "允許",
					relationship_reject_button = "拒絕",
					------ setting scene > contact scene
					contact_headerTitle = "聯絡我們",
					contact_partnership = "合作關係",
					contact_content = "如果你想加入我們作推廣，請聯絡我們。",
					contact_phoneTo = "打電話到 %s？",
					------ setting scene > tutorial scene
					tutorial_skip = "跳過",
					------ setting scene > redemption scene
					redemption_headerTitle = "換領",
					redemption_noCoupon = "沒有優惠劵",
					redemption_MoreThan1Day = "多於一日",
					redemption_Invalid = "失效",
					redemption_Remain = "尚餘 ",
					redemption_Hour = " 小時 ",
					redemption_Min = " 分 ",
					redemption_Sec = " 秒",
					------ setting scene > redemption scene > coupon scene
					coupon_headerTitle = "優惠劵",
					------ setting scene > about vorum scene
					aboutVorum_headerTitle = "關於Vorum",
					-- aboutVorum_appIntro = "Vorum是一個投票的論壇。 收集大家對各種事物的意見和看法。",
					-- aboutVorum_appDesc = "Vorum是第一個分享益處的手機應用程式。 所有的使用者都有機會透過分享他們的意見和見法來獲得益處。",
					-- aboutVorum_contactWay = "尋找更多資料:",
					-- aboutVorum_facebookContact = "Facebook: ",
					-- aboutVorum_emailContact = "電郵: ",
					-- aboutVorum_websiteContact  = "網站: ",
					aboutVorumDesc1 = {
										"Vorum - 一個以最少字為主的投票論壇",
										"我們簡單地展示圖片和選擇，討論直接，容易理解。",
										"Vorum - 一個收集別人意見的平台",
										"你可以收集別人意見，改變世界。",
										"Vorum - 一個分享收益的手機應用程式",
										"用家參與就是成功的關鍵。我們了解用家的貢獻的重要性，因此我們在營運模式中加入了分享收益的機制。",
										"任何用家都能夠有機會由 Vorum 分享的廣告收益。",
										"按此進入我們的網頁：",
										},
					aboutVorumDesc2 = {
										"看看如何可以創造與別不同的世界，以及獲取額外收益。",
										"以電郵與我們聯絡：",
									},
					------ profile scene
					profile_unfriend = "絕交",
					------ cat screen
					cat_headerTitle = "類別",
					cat_headerLeftButton = "返回",
					cat_headerRightButton = "完成",
					cat_tag = "標籤",
					cat_latest = "最新",
					cat_mostVoted = "最多投票",
					cat_mostVoted_all = "全部",
					cat_mostVoted_week = "1周",
					cat_mostVoted_month = "1個月",
					cat_all = "全部",
					cat_30mins = "30分鐘",
					cat_anonymous = "匿名",
					cat_appraisal = "評核",
					cat_general = "總匯",
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
					search_post = "帖子",
					search_people = "人物",
					search_post_noResult = "沒有結果",
					search_people_noResult = "沒有結果",

					---------- function
					--addPhoto
					addPhoto_takePhoto = "相機",
					addPhoto_pickPhoto = "圖片庫",
					addPhoto_deletePhoto = "移除",
					addPhoto_cancel = "取消",
					--postButton
					postButton_push = "推",
					postButton_report = "報告",
					postButton_share = "分享",
					postButton_shareToWhatsapp = "分享到whatsapp",
					postButton_shareToFacebook = "分享到面書",
					postButton_shareToMyWall = "分享到我的帖子",
					postButton_delete = "刪除",
					postButton_cancel = "取消",

		
					--login error
					loginError_errorTitle = "登入錯誤",
					loginError_emptyUsername = "你必須輸入名稱",
					loginError_emptyPassword = "你必須輸入密碼",
					loginError_wrongData = "你的名稱或密碼錯誤",
					loginError_emailNoAt = "電郵地址無效",
					loginError_emailNoVerified = "你的電郵地址尚未認證。重發確認電郵？",
					--register success
					registerSuccess_registerTitle = "註冊成功",
					registerSuccess_register = "你將會收到一封激活帳號的電子郵件。請激活你的帳號後登入。",
					resendVerificationEmail = "己發出確認電郵",
					--register fail
					registerFail_registerTitle = "註冊失敗",
					registerFail_invalidEmail = "電郵地址無效。",
					registerFail_emailAlreadyRegistered = "電郵地址已經被註冊。",
					--update userData success
					updateUserDataSuccess_updateTitle = "更新成功",
					updateUserDataSuccess_update = "更新個人資料成功。",
					--network error
					networkError_errorTitle = "網絡錯誤",
					networkError_networkError = "無法連接網絡，請檢查網絡。",
					--4 button(push,report,share,delete) error
					pushPostError_pushTitle = "推帖子錯誤",
					pushPostError_pushedAleady = "今天你已經推過這帖子。",
					sharePostError_shareTitle = "分享錯誤",
					sharePostError_sharedAleady = "今天你已經分享過這帖子。",
					
					--4 button(push,report,share,delete) success
					pushPostSuccessTitle = "推帖子成功",
					reportPostSuccessTitle = "報告成功",
					sharePostSuccessTitle = "分享成功",
					deletePostSuccessTitle = "刪除成功",
					
					pushPostSuccess = "推帖子成功。",
					reportPostSuccess = "報告成功。",
					sharePostSuccess = "分享成功。",
					deletePostSuccess = "刪除成功。",
					--create post and new coupon success
					newPostSuccessTitle = "創建帖子成功",
					newCouponSuccessTitle = "創建帖子和優惠卷成功",
					newPostSuccess = "創建帖子成功。",
					newCouponSuccess = "創建帖子和優惠卷成功。",
					--create new post error
					networkError_newPost = "網絡錯誤，帖子無法創建。" ,
					networkError_newCoupon = "網絡錯誤，優惠劵無法創建。",
					--necessary input
					necessaryInput_title = "必須輸入部份資料",
					necessaryInput_post1Title = "你必須輸入標題",
					necessaryInput_post2ChoiceA = "最少必須輸入2個選項。",
					necessaryInput_post2ChoiceB = "最少必須輸入2個選項。",
					necessaryInput_post2FillChoiceDEmptyChoiceC = "你必須輸入選項C才能輸入選項D。",
					--input check
					inputCheck_title = "你的輸入超出字符限制",
					inputCheck_passwordDiffTitle = "密碼和確認密碼必須一樣",
					inputCheck_passwordDiff = "密碼和確認密碼必須一樣。",
					inputCheck_mustFillTitle = "必須輸入部份資料",
					inputCheck_fillEmail = "必須輸入電子郵件。",
					inputCheck_fillPassword = "必須輸入密碼。",
					inputCheck_fillConfirmedPassword = "必須輸入確認密碼。",
					inputCheck_fillName = "必須輸入名稱。",
					inputCheck_emailNoAtTitle = "錯誤的電郵地址",
					inputCheck_emailNoAt = "請檢查你的電子郵件來是否正確。",
					inputCheck_chooseGender = "你必須選擇性別。",
					inputCheck_agreeCheckBoxTitle = "服務條款和私隱政策",
					inputCheck_agreeCheckBox = "你必須同意服務條款和私隱政策。",
					inputQuestion_limited = "問題描述不能超過30個字符。",
					inputDesc_limited = "描述不能超過100個字符。",
					inputPost2Desc_limited = "選項描述不能超過30個字符。",
					inputCouponTitle_limited = "優惠劵描述不能超過200個字符。",
					post3CouponDataNotEnoughTitle = "優惠劵資料不足",
					post3CouponDataNotEnough = "優惠劵資料需同時要有描述與圖片。",
					post3InputCheckTitle = "沒有優惠卷。",
					post3InputCheck_noCouponHideResult = "你必須有優惠卷才能隱藏結果。",
					--register GPS
					GPS_openGpsTitle = "請開啟你的GPS",
					GPS_openGps = "你不能使用'我的國家'功能，如果你不開啟GPS。 你還想註冊嗎?",
					
					GPS_openGpsOption_open = "取消",
					GPS_openGpsOption_continue = "繼續",
					--birthday error
					birthdayError_title = "生日日期錯誤",
					birthdayError_noThatDay = "這個月沒有這一天",
					birthdayError_overNow = "生日日子錯誤",
					redemption_noCoupon = "沒有優惠卷",
					--personal part
					personalInfo_voted = " 投票",
					personalInfo_posts = " 帖子",
					
					--facebook choice
					ok = "好",
					cancel = "取消",
					retry = "重試",

					-- Facebook Login Procedure
					fb_inputLoginData = "請輸入資料",
					fb_inputLoginDataToLink = "請在下方輸入帳戶資料",
					fb_noFbAcc = "無法找到 Facebook 帳戶",
					fb_noFbAcc_Create = "無法找到與 Facebook 連結的帳戶。建立新帳戶，或連結現有帳戶？",
					create = "建立",
					link = "連結",
					fb_createAcc = "建立帳戶",
					fb_createNewAcc = "建立新帳戶？",
					fb_linkToAcc = "連結現有帳戶",
					fb_linkFbToAcc = "把 Facebook 帳戶與現有帳戶連結？",
					fb_cantLoginAccToLink = "無法連結此帳戶",
					fb_accountLinked = "帳戶已連結",
					fb_accountLinkedSuccessfully = "此帳戶已與 Facebook 帳戶連結",
					fb_cannotRetrieveFacebookData = "無法獲取 Facebook 帳戶資料",
					fb_cantLoginAccToLink_Retry = "無法登入帳戶，重試？",
					fb_notVerifiedAccToLink_Retry = "帳戶未核實，所以不能連結。以另一帳戶重試？",
					fb_accAlreadyLinked_Retry = "此帳戶已與其他 Facebook 帳戶連結。以另一帳戶重試？",
					yes = "是",
					no = "否",


					-- Post
					anonymous = "匿名",
					justNow = "現在",
					minAgo = " 分鐘前",
					minsAgo = " 分鐘前",
					hourAgo = " 小時前",
					hoursAgo = " 小時前",
					createAtYear = " 年 ",
					createAtMonth = " 月 ",
					createAtDay = " 日",
					post_MyPost = "我的帖子",
					post_Rewards = "獎賞",
					view = " 瀏覽",
					views = " 瀏覽",
					voted = " 投票",
					expireTime_MoreThan30Mins = "> 30 分鐘",
					expireTime_Expired = "逾時",
					expireTime_Remain = "尚餘 ",
					post_PleaseGoToSettingRedemptionToSeeCoupon = "請前往 設定 > 換領 以獲取優惠劵",
					post_ClickHereToGoToRedemptionPage = "按此前往\"換領\"以獲取優惠劵",
					post_Result = "結果",
					post_noVote = "沒有投票",
					post_same = "相同",
					post_maleLetter = "男",
					post_femaleLetter = "女",
					post_updatingResult = "正在更新結果⋯",
					post_deleting = "刪除中⋯",
					
					-- voting
					alreadyVotePost = "你已對此帖投票",

					--register>termAndConitions
					termsAndConitions_title = "服務條款和私隱政策",
					
					sharePostSentence1 = "Vorum 有新帖！",
					sharePostSentence2 = "按下鏈結下載 Vorum 投票！",
					
					-- friend request
					friendRequest_alreadyRequest = "你已經請求成為朋友。",
					friendRequest_alreadyRequest_cancel = "你已經請求成為朋友。取消？",
					
					--forgetPassword
					forgetPasswordErrorTitle_noEmail = "錯誤的電郵地址",
					forgetPasswordErrorDesc_noEmail = "請檢查你的電子郵件來是否正確。",
					forgetPasswordSuccessTitle = "重設密碼的電子郵件已送出",
					forgetPasswordSuccessDesc = "請檢查你的電子郵件來重設密碼。",
					

					--facebook share
					facebookShareSuccessTitle = "分享成功",
					facebookShareSuccessDesc = "成功分享到Facebook。",
					facebookShareErrorTitle = "分享失敗",
					facebookShareErrorDesc = "分享到Facebook失敗。",

					--
					noPost = "沒有帖子",
					
					--notice is not work
					noticeNotWorkTitle = "通知",
					noticeNotWorkDesc = "通知頁面尚未開放。",

					-- Tag
					Appraisal = "評核",
					Anonymous = "匿名",
					General = "總匯",
					["30mins"] = "30 分鐘",
					All = "所有",
					
					helloString = "Hello",
					listString = {
									"Row 1",
									"Row 2",
									"Row 3",
									},
					},
		}
