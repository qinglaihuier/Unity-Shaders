Shader "Unity Shaders Book/Chapter-15/FogWithNoiseShader"{
    Properties{
        _MainTex("MainTex",2D) = "white"{}
        _FogNoise("FogNoise",2D) = "white"{}
        _FogColor("FogColor",Color) = (1,1,1,1)
        _FogStart("FogStart",Float) = 0
        _FogEnd("FogEnd",Float) = 20
        _FogDensity("FogDensity",Range(0,1)) = 1
        _NoiseAmount("NoiseAmount",Range(0,1)) = 1
        _SpeedX("SpeedX" , Float) = 1
        _SpeedY("SpeedY",Float) = 1
    }
    SubShader{
        CGINCLUDE
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float2 _MainTex_TexelSize;
            sampler2D _FogNoise;
            sampler2D _CameraDepthTexture;
            float4x4 _FruscumCorner;
            fixed4 _FogColor;
            float _FogStart;
            float _FogEnd;
            fixed _FogDensity;
            fixed _NoiseAmount;
            float _SpeedX;
            float _SpeedY;

            struct a2v{
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD;  
            };
            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv_mainTex : TEXCOORD;
                float2 uv_depth : TEXCOORD1;
                float3 direction : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv_mainTex = v.texcoord;
                o.uv_depth = v.texcoord;

                #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_TexelSize.y<0){
                        o.uv_depth = 1 - o.uv_depth;
                    }
                #endif

                int index = 0;
                if(v.texcoord.x < 0.5 && v.texcoord.y < 0.5){
                    index = 0;
                }
                if(v.texcoord.x > 0.5 && v.texcoord.y < 0.5){
                    index = 1;
                }
                if(v.texcoord.x > 0.5 && v.texcoord.y > 0.5){
                    index = 2;
                }
                if(v.texcoord.x < 0.5 && v.texcoord.y > 0.5){
                    index = 3;
                }
                #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_TexelSize.y<0){
                        index = 3 - index;
                    }
                #endif

                o.direction = float3(_FruscumCorner[index].xyz);

                return o;
            }
            fixed4 frag(v2f i):SV_TARGET{
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
                
                fixed noise = tex2D(_FogNoise,i.uv_mainTex + float2(_SpeedX,_SpeedY) * _Time.y).r;

                noise = (noise - 0.5) * _NoiseAmount;

                float3 worldPos = _WorldSpaceCameraPos.xyz + depth * i.direction;

                fixed fogDnsity = saturate((_FogEnd - worldPos.y)/(_FogEnd - _FogStart));
 
                fogDnsity =saturate( fogDnsity * _FogDensity * (1 + noise));  //注意截断

                fixed3 color = tex2D(_MainTex,i.uv_mainTex).rgb;

                return fixed4(color * (1 - fogDnsity) + _FogColor * fogDnsity,1);
            }
        ENDCG
        Pass{
            CGPROGRAM
                #pragma vertex vert;
                #pragma fragment frag;
            ENDCG
        }
    }
    Fallback Off
}