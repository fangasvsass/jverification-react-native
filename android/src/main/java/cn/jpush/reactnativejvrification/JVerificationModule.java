package cn.jpush.reactnativejvrification;

import android.Manifest;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import cn.jiguang.verifysdk.api.JVerificationInterface;
import cn.jiguang.verifysdk.api.VerifyListener;
import cn.jiguang.verifysdk.api.JVerifyUIClickCallback;
import cn.jiguang.verifysdk.api.JVerifyUIConfig;
import cn.jpush.reactnativejvrification.utils.AndroidUtils;

public class JVerificationModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    private static String TAG = "JVerificationModule";

    private static final int CODE_PERMISSION_GRANTED = 0;
    private static final String MSG_PERMISSION_GRANTED = "Permission is granted";
    private static final int ERR_CODE_PERMISSION = 1;
    private static final String ERR_MSG_PERMISSION = "Permission not granted";

    //"android.permission.READ_PHONE_STATE"
    private static final String[] REQUIRED_PERMISSIONS = new String[]{Manifest.permission.READ_PHONE_STATE};

    private boolean requestPermissionSended;
    private Callback permissionCallback;

    public JVerificationModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addLifecycleEventListener(this);
    }

    @Override
    public boolean canOverrideExistingModule() {
        return true;
    }

    @Override
    public String getName() {
        return "JVerificationModule";
    }

    @Override
    public void initialize() {
        super.initialize();
    }

    @ReactMethod
    public void setup(ReadableMap map) {
        JVerificationInterface.init(getCurrentActivity());
    }

    @ReactMethod
    public void requestPermission(Callback permissionCallback) {
        if (AndroidUtils.checkPermission(getCurrentActivity(), REQUIRED_PERMISSIONS)) {
            doCallback(permissionCallback, CODE_PERMISSION_GRANTED, MSG_PERMISSION_GRANTED);
            return;
        }
        this.permissionCallback = permissionCallback;
        Log.i(TAG, "requestPermission");
        try {
            AndroidUtils.requestPermission(getCurrentActivity(), REQUIRED_PERMISSIONS);
            requestPermissionSended = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @ReactMethod
    public void setDebug(boolean enable) {
        JVerificationInterface.setDebugMode(enable);
    }

    @ReactMethod
    public void getToken(final Callback callback) {
        JVerificationInterface.getToken(getCurrentActivity(), new VerifyListener() {
            @Override
            public void onResult(int code, String content, String operato) {
                doCallback(callback, code, content);
            }
        });
    }

    @ReactMethod
    public void verifyNumber(ReadableMap map, final Callback callback) {
        String number = map.getString("number");
        String token = map.getString("token");

        JVerificationInterface.verifyNumber(getCurrentActivity(), token, number, new VerifyListener() {
            @Override
            public void onResult(int code, String content, String operator) {
                doCallback(callback, code, content);
            }
        });
    }

    @ReactMethod
    public void loginAuth(final Callback callback) {
//        boolean verifyEnable = JVerificationInterface.checkVerifyEnable(this);
//        if (!verifyEnable) {
//            return;
//        }
        ImageButton mBtn = new ImageButton(this.getCurrentActivity());
//        mBtn.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
        RelativeLayout.LayoutParams mLayoutParams1 = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        mLayoutParams1.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        mLayoutParams1.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        mLayoutParams1.setMargins(200, 0, 0, 250);
        mBtn.setBackgroundResource(R.drawable.native_phone_number_login);
        mBtn.setLayoutParams(mLayoutParams1);

        ImageButton mBtn2 = new ImageButton(this.getCurrentActivity());
//        mBtn.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
        RelativeLayout.LayoutParams mLayoutParams2 = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        mLayoutParams2.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        mLayoutParams2.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        mLayoutParams2.setMargins(0, 0, 200, 250);
//        mLayoutParams2.setMargins(dp2Pix(this,250), dp2Pix(this,450.0f),dp2Pix(this,50),50);
        mBtn2.setBackgroundResource(R.drawable.native_wechat_login);
        mBtn2.setLayoutParams(mLayoutParams2);



        ViewGroup viewGroup= (ViewGroup) getCurrentActivity().getLayoutInflater().inflate(R.layout.line,null);
//        mBtn.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
        RelativeLayout.LayoutParams mLayoutParams3 = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        mLayoutParams3.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        mLayoutParams3.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        mLayoutParams3.setMargins(0, 0, 0, 500);

//        mLayoutParams2.setMargins(dp2Pix(this,250), dp2Pix(this,450.0f),dp2Pix(this,50),50);
        viewGroup.setLayoutParams(mLayoutParams3);

        JVerifyUIConfig uiConfig = new JVerifyUIConfig.Builder()
                .setNavColor(0xffffffff)
                .setNavReturnImgPath("native_close")
                .setLogoImgPath("native_login_icon")
                .setNavText("登录")
                .setNavTextColor(0xffffffff)
                .setLogoWidth(122)
                .setLogoHeight(45)
                .setLogoHidden(false)
                .setNumberColor(0xff333333)
                .setLogBtnText("一键登入")
                .setLogBtnTextColor(0xffffffff)
                .setLogBtnImgPath("native_login_bg")
//                .setAppPrivacyOne("应用自定义服务条款一","https://www.jiguang.cn/about")
//                .setAppPrivacyTwo("应用自定义服务条款二","https://www.jiguang.cn/about")
                .setAppPrivacyColor(0xff666666, 0xff0085d0)
                .setUncheckedImgPath("umcsdk_uncheck_image")
                .setCheckedImgPath("umcsdk_check_image")
                .setSloganTextColor(0xff999999)
                .setLogoOffsetY(50)
                .setNumFieldOffsetY(170)
                .setSloganOffsetY(215)
                .setLogBtnOffsetY(254)
                .addCustomView(mBtn, true, new JVerifyUIClickCallback() {
                    @Override
                    public void onClicked(Context context, View view) {
                        try {
                            doCallback(callback, 8000, "");
                        } catch (Exception e) {
                        }

                    }
                }).addCustomView(mBtn2, true, new JVerifyUIClickCallback() {
                    @Override
                    public void onClicked(Context context, View view) {
                        try {
                            doCallback(callback, 9000, "");
                        } catch (Exception e) {
                        }
                    }
                })
                .addCustomView(viewGroup, true, new JVerifyUIClickCallback() {
                    @Override
                    public void onClicked(Context context, View view) {

                    }
                })
                .setPrivacyOffsetY(30).build();
        JVerificationInterface.setCustomUIWithConfig(uiConfig);
//        JVerificationInterface.setLoginAuthLogo("umcsdk_mobile_logo","umcsdk_mobile_logo","umcsdk_mobile_logo");
        JVerificationInterface.loginAuth(this.getCurrentActivity(), new VerifyListener() {
            @Override
            public void onResult(final int code, final String content, final String operator) {
                try {
                    doCallback(callback, code, content,operator);
                } catch (Exception e) {
                }
            }
        });
    }

    @Override
    public void onHostResume() {
        if (requestPermissionSended) {
            if (AndroidUtils.checkPermission(getCurrentActivity(), REQUIRED_PERMISSIONS)) {
                doCallback(permissionCallback, CODE_PERMISSION_GRANTED, MSG_PERMISSION_GRANTED);
            } else {
                doCallback(permissionCallback, ERR_CODE_PERMISSION, ERR_MSG_PERMISSION);
            }
        }
        requestPermissionSended = false;

    }

    @Override
    public void onHostPause() {

    }

    @Override
    public void onHostDestroy() {

    }

    private void doCallback(Callback callback, int code, String content,String operator) {
        WritableMap map = Arguments.createMap();
        map.putInt("code", code);
        map.putString("loginToken", content);
        map.putString("operator", operator);
        callback.invoke(map);
    }

    private void doCallback(Callback callback, int code, String content) {
        doCallback(callback,code,content,null);
    }
}