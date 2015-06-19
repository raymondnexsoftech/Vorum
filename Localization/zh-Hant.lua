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
					
					notice_action_postVoted = "你的帖子\"",
					notice_action_postVoted2 = "\"被投票了。",
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
					redemption_getCouponByVoting = "你可投票有\"獎賞\"標記的帖子獲得優惠劵",
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
					postButton_report = "舉報",
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
					loginError_AssociatedEmailNoVerified = "你的電郵地址 \"%s\" 尚未認證。重發確認電郵？",
					--register success
					registerSuccess_registerTitle = "註冊成功",
					registerSuccess_register = "你將會收到一封激活帳號的電子郵件。請激活你的帳號後登入。",
					resendVerificationEmail = "己發出確認電郵",
					--register fail
					registerFail_registerTitle = "註冊失敗",
					registerFail_invalidEmail = "電郵地址無效。",
					registerFail_emailAlreadyRegistered = "電郵地址已經被註冊。",
					registerFail_ErrorOccurred = "錯誤碼: %s, 訊息: %s",
					--update userData success
					updateUserDataSuccess_updateTitle = "更新成功",
					updateUserDataSuccess_update = "更新個人資料成功。",
					--network error
					networkError_errorTitle = "網絡錯誤",
					networkError_networkError = "無法連接網絡，請檢查網絡。",

					--4 button(push,report,share,delete) error
					pushPostError_pushedAlreadyTitle = "推帖子失敗",
					pushPostError_pushedAlreadyDesc = "你今天已經推過帖子了。",
					reportPostError_reportAlreadyTitle = "舉報帖子失敗",
					reportPostError_reportAlreadyDesc = "你已經舉報過這帖子了。",
					
					--4 button(push,report,share,delete) success
					pushPostSuccessTitle = "推帖成功。",
					reportPostSuccessTitle = "舉報成功",
					sharePostSuccessTitle = "分享成功",
					deletePostSuccessTitle = "刪除成功",

					pushPostSuccess = "現在帖子己排在\"最新\"的頂部。",
					reportPostSuccess = "多謝你的意見，我們會盡快檢查此帖。",
					sharePostSuccess = "此帖已分享到你的牆上。",
					deletePostSuccess = "刪除成功。",

					sharePostFailed = "分享帖子失敗",
					cannotShareThisPost = "未能分享此帖子到你的牆上。",
					creatorOrAlreadyShared = "你是此帖作者，或你已分享此帖子。",
					friendPostCannotBeShared = "只限朋友的帖子不能分享。",
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
					inputPost2Desc_limited = "選項描述 %s 不能超過30個字符。",
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
					fb_foundAcc = "找到帳戶",
					fb_linkWithThisEmail = "找到使用 %s 的帳戶. 與此帳戶連結？",
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
					postDoesNotExist = "此帖已不存在",

					-- voting
					alreadyVotePost = "你已對此帖投票",

					--register>termAndConitions
					termsAndConitions_title = "服務條款和私隱政策",
					
					sharePostSentence1 = "對以下標題有意見？",
					sharePostSentence2 = "按下鏈結下載 Vorum 投票！",
					
					-- friend request
					friendRequest_alreadyRequest = "你已經請求成為朋友。",
					friendRequest_alreadyRequest_cancel = "你已經請求成為朋友。取消？",
					friendRequest_requestSent = "請求已送出",
					friendRequest_requestSent_Body = "你向\"%s\"的朋友請求已送出。",
					friendRequest_requestCancelled = "請求已取消",
					friendRequest_requestCancelled_Body = "已取消你向\"%s\"的朋友請求。",
					friendRequest_confirmUnfriend = "確認移除好友",
					friendRequest_confirmUnfriend_Body = "確認要將\"%s\"移除好友？",
					friendRequest_confirmReject = "確認拒絕成為朋友",
					friendRequest_confirmReject_Body = "確認要拒絕\"%s\"的朋友請求？",
					friendRequest_nowFriend = "已成為朋友",
					friendRequest_nowFriend_Body = "你與\"%s\"已成為朋友。",

					--forgetPassword
					forgetPasswordErrorTitle_noEmail = "錯誤的電郵地址",
					forgetPasswordErrorDesc_noEmail = "請檢查你的電子郵件來是否正確。",
					forgetPasswordSuccessTitle = "重設密碼的電子郵件已送出",
					forgetPasswordSuccessDesc = "己送出電子郵件至 %s。請檢查你的電子郵件來重設密碼。",

					--facebook share
					facebookShareSuccessTitle = "分享成功",
					facebookShareSuccessDesc = "成功分享到Facebook。",
					facebookShareErrorTitle = "分享失敗",
					facebookShareErrorDesc = "分享到Facebook失敗。",

					--
					noPost = "沒有帖子",
					noNotic = "沒有通知",
					
					--notice is not work
					noticeNotWorkTitle = "通知",
					noticeNotWorkDesc = "通知頁面尚未開放。",

					--4 button(push,report,share,delete) failed
					pushPostFailedTitle = "推帖子失敗",
					reportPostFailedTitle = "舉報帖子失敗",
					sharePostFailedTitle = "分享帖子失敗",
					deletePostFailedTitle = "刪除帖子失敗",
					
					pushPostFailedDesc = "推帖子失敗。",
					reportPostFailedDesc = "舉報帖子失敗。",
					sharePostFailedDesc = "分享帖子失敗。",
					deletePostFailedDesc = "刪除帖子失敗。",

					deletePostConfirmTitle = "你真的想刪除這帖子嗎？",
					deletePostConfirmDesc = "如果是，這個帖子將會永久刪除，不能復原。",
					--
					unknownErrorTitle = "未知錯誤",
					unknownErrorDesc = "未知錯誤。",

					forgetPassword_popupInput = "請輸入你的電郵地址：",

					-- Contact Email
					contactEmailSubject = "Vorum App 聯絡我們",
					contactEmailBody = "Vorum 團隊，你們好，我們聯絡 Vorum 團隊是因為：",

					searchScreen_by = "自 ",

					-- refresh bar
					textToPull = "向下拉準備重新載入",
					textToRelease = "放手重新載入",
					loadingText = "重新載入中⋯",

					-- T & C
					TermsAndCondition = {
											"Terms and Conditions (\"Terms\")\n\nLast updated: June 13, 2015\n\nPlease read these Terms and Conditions (\"Terms\", \"Terms and Conditions\") carefully before using the Vorum mobile application (the \"Service\") operated by Vorum Incorporation Limited (\"us\", \"we\", or \"our\").\n\nYour access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users and others who access or use the Service.\n\nBy accessing or using the Service you agree to be bound by these Terms. If you disagree with any part of the terms then you may not access the Service.",
											"Content\n\nOur Service allows you to post, link, store, share and otherwise make available certain information, text, graphics, videos, or other material (\"Content\"). You are responsible for the Content that you post to the Service, including its legality, reliability, and appropriateness.\n\nBy posting Content to the Service, you grant us the right and license to use, modify, publicly perform, publicly display, reproduce, and distribute such Content on and through the Service. You retain any and all of your rights to any Content you submit, post or display on or through the Service and you are responsible for protecting those rights. You agree that this license includes the right for us to make your Content available to other users of the Service, who may also use your Content subject to these Terms.\n\nYou represent and warrant that: (i) the Content is yours (you own it) or you have the right to use it and grant us the rights and license as provided in these Terms, and (ii) the posting of your Content on or through the Service does not violate the privacy rights, publicity rights, copyrights, contract rights or any other rights of any person.",
											"Accounts\n\nWhen you create an account with us, you must provide us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.\n\nYou are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password, whether your password is with our Service or a third-party service.\n\nYou agree not to disclose your password to any third party. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.\n\nYou may not use as a username the name of another person or entity or that is not lawfully available for use, a name or trade mark that is subject to any rights of another person or entity other than you without appropriate authorization, or a name that is otherwise offensive, vulgar or obscene.",
											"Intellectual Property\n\nThe Service and its original content (excluding Content provided by users), features and functionality are and will remain the exclusive property of Vorum Incorporation Limited and its licensors. The Service is protected by copyright, trademark, and other laws of both the Hong Kong and foreign countries. Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of Vorum Incorporation Limited.",
											"Links To Other Web Sites\n\nOur Service may contain links to third-party web sites or services that are not owned or controlled by Vorum Incorporation Limited.\n\nVorum Incorporation Limited has no control over, and assumes no responsibility for, the content, privacy policies, or practices of any third party web sites or services. You further acknowledge and agree that Vorum Incorporation Limited shall not be responsible or liable, directly or indirectly, for any damage or loss caused or alleged to be caused by or in connection with use of or reliance on any such content, goods or services available on or through any such web sites or services.\n\nWe strongly advise you to read the terms and conditions and privacy policies of any third-party web sites or services that you visit.",
											"Termination\n\nWe may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.\n\nUpon termination, your right to use the Service will immediately cease. If you wish to terminate your account, you may simply discontinue using the Service.",
											"Limitation Of Liability\n\nIn no event shall Vorum Incorporation Limited, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your access to or use of or inability to access or use the Service; (ii) any conduct or content of any third party on the Service; (iii) any content obtained from the Service; and (iv) unauthorized access, use or alteration of your transmissions or content, whether based on warranty, contract, tort (including negligence) or any other legal theory, whether or not we have been informed of the possibility of such damage, and even if a remedy set forth herein is found to have failed of its essential purpose.",
											"Disclaimer\n\nYour use of the Service is at your sole risk. The Service is provided on an \"AS IS\" and \"AS AVAILABLE\" basis. The Service is provided without warranties of any kind, whether express or implied, including, but not limited to, implied warranties of merchantability, fitness for a particular purpose, non-infringement or course of performance.\n\nVorum Incorporation Limited its subsidiaries, affiliates, and its licensors do not warrant that a) the Service will function uninterrupted, secure or available at any particular time or location; b) any errors or defects will be corrected; c) the Service is free of viruses or other harmful components; or d) the results of using the Service will meet your requirements.",
											"Governing Law\n\nThese Terms shall be governed and construed in accordance with the laws of Hong Kong, without regard to its conflict of law provisions.\n\nOur failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. If any provision of these Terms is held to be invalid or unenforceable by a court, the remaining provisions of these Terms will remain in effect. These Terms constitute the entire agreement between us regarding our Service, and supersede and replace any prior agreements we might have between us regarding the Service.",
											"Changes\n\nWe reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material we will try to provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.\n\nBy continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms. If you do not agree to the new terms, please stop using the Service.",
											"Contact Us\n\nIf you have any questions about these Terms, please contact us."
										},
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
