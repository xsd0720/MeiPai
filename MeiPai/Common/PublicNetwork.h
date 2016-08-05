//
//  PublicNetwork.h
//  MeiPai
//
//  Created by xwmedia01 on 15/7/29.
//  Copyright (c) 2015年 zp. All rights reserved.
//

#ifndef MeiPai_PublicNetwork_h
#define MeiPai_PublicNetwork_h


/**
 *  请求头(测试)
 */

#ifdef DEBUG

#define HttpHead            @"http://192.168.20.247:8000"

//#define HttpHead             @"182.92.23.2"

#define ShareHttpHead        @"http://lilslb.com"

#else

//#define HttpHead             @"182.92.23.2"
#define HttpHead            @"123.57.207.48"

#define ShareHttpHead        @"http://lilslb.com"

#endif


#pragma mark -  account(账号) -
/**
 *  注册
 */
#define RegisURL              @"/account/register"

/**
 *  登录
 */
#define LoginURL              @"/account/login"

/**
 *  登出
 */
#define LogoutURL             @"/account/logout"

/**
 *  忘记密码
 */
#define ForgetURL             @"/account/forget"

/**
 *  个人简介
 */
#define ProfileURL            @"/account/profile"

/**
 *  个人简介更新
 */
#define UpdateURL             @"/account/update"

/**
 *  手机号码修改
 */
#define UpdatemobileURL       @"/account/updatemobile"

/**
 *  用户名修改
 */
#define UpdateusernameURL     @"/account/updateusername"



/**
 *  发送验证码
 */
#define RequestsnsURL         @"/account/requestsns"

/**
 *  验证验证码
 */
#define CheckvcodeURL         @"/account/checkvcode"


/**
 *  忘记密码修改密码
 */
#define UpdateuserpsdURL     @"/account/updateuserpsd"

/**
 *  修改头像
 */
#define Changeheadpic         @"/account/changeheadpic"


#endif
