local global = {}
--data saving part
global.languageDataPath = "language.sav"
global.userDataPath = "user/userData.sav"

global.post3TagsDataPath = "newPost/tags.sav"

global.searchDataPath = "search.sav"
global.catSettingDataPath = "category.sav"
--profile
global.sceneTransDataPath = "sceneTransData.sav"

global.vorumTabFilterDataPath = "vorumTabFilter.sav"
global.meTabFilterDataPath = "meTabFilter.sav"

--post image
global.registerImagePath = "registerIcon.jpg"
global.updateIconImage = "updateIcon.jpg"
global.post1TitleImage = "question.jpg"
global.post2ChoiceAImage = "postChoiceA.jpg"
global.post2ChoiceBImage = "postChoiceB.jpg"
global.post2ChoiceCImage = "postChoiceC.jpg"
global.post2ChoiceDImage = "postChoiceD.jpg"
global.post3CouponImage = "newCoupon.jpg"

global.tutorialSavePath = "user/tutorial.sav"

global.TEMPBASEDIR = system.TemporaryDirectory

global.currentSceneNumber = 3

global.newSceneHeaderOption = {
								dir = "left",
								time = 300,
								transition = easing.outQuad,
							}
												
global.backSceneHeaderOption = {
								dir = "right",
								time = 300,
								transition = easing.outQuad,
							}									
global.backSceneOption = {
							effect = "slideRight",
							time = 400,
							params = {
										changeHeaderOption = {
											dir = "right",
											time = 300,
											transition = easing.outQuad,
										},
									 }
						}

-- color
global.maleColor = {88/255,175/255,231/255}
global.femaleColor = {255/255,167/255,177/255}
global.noGenderColor = {170/255,170/255,170/255}

						
return global