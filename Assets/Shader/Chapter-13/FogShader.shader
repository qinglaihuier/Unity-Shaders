Shader "Unity Shaders Book/Chapter-13/FogShader"{
    Properties{
        _MainTex("MainTex",2D) = "white"{}
        _FogDestiny("FogDestiny",Float) = 0.5
        _FogColor("FogColor",Color) = (0,0,0,0)
        _FogStartHeight("FogStartHeight",Float) = 20
        _FogEndHeight("FogEndHeight",Float) = 100
    }
    SubShader{  
        ZTest Always ZWrite Off Cull Off
        CGINCLUDE
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members position_deviation)
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _FogDestiny;
            fixed4 _FogColor;
            float _FogStartHeight;
            float _FogEndHeight;
            sampler2D _CameraDepthTexture;
            float4x4 _FrustumCorner;

            struct v2f{
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD;
                half2 uv_depth : TEXCOORD2;
                float3 position_deviation:TEXCOORD1;
            };

            v2f vert(appdata_img v){
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;
                o.uv_depth = v.texcoord;

                half2 uv = o.uv;

                int index = 0;

                if(uv.x < 0.5 && uv.y > 0.5){
                    index = 0;
                }
                if(uv.x > 0.5 && uv.y > 0.5){
                    index = 1;
                }
                if(uv.x < 0.5 && uv.y < 0.5){
                    index = 2;
                }
                if(uv.x > 0.5 && uv.y < 0.5){
                    index = 3;
                }

                 #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_TexelSize.y < 0){
                        o.uv_depth = 1 - o.uv_depth;
                        index = 3 - index;
                    }
                #endif

                o.position_deviation = _FrustumCorner[index];

                return o;
            }
            fixed4 frag(v2f i):SV_TARGET{
                fixed d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth);

                float lineDepth = LinearEyeDepth(d);

                float3 worldPos = _WorldSpaceCameraPos.xyz + i.position_deviation * lineDepth;

                float destiny = (_FogEndHeight - worldPos.y)/(_FogEndHeight - _FogStartHeight);

                destiny = saturate(destiny * _FogDestiny);

                fixed4 finalColor = tex2D(_MainTex,i.uv);

                return finalColor*(1 - destiny) + _FogColor * destiny;
            }
        ENDCG
        Pass{
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
            ENDCG
        }
    }
    Fallback Off 
}