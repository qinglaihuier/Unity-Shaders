using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithNoise :PostEffectsBase
{
    // Start is called before the first frame update
   Material fogWithNoiseMat;
   [SerializeField]Shader fogWithNoiseShader;
   public Material material{
        get{
            fogWithNoiseMat = CheckShaderAndCreateMaterial(fogWithNoiseShader,fogWithNoiseMat);
            return fogWithNoiseMat;
        }
   }
   public Texture fogNoise;
   public Color fogColor = Color.gray;
   public float fogStart = 0;
   public float fogEnd = 20;
   [Range(0,1)]public float fogDensity = 1;
   [Range(0,1)]public float noiseAmount = 1;
   public float speedX;
   public float speedY;
   Camera fogWithNoiseCamera;
   private void Awake() {
        fogWithNoiseCamera = GetComponent<Camera>();
   }
   private void OnEnable() {
        fogWithNoiseCamera.depthTextureMode |= DepthTextureMode.Depth;
   }
   private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if(material){
            Transform cameraTr = fogWithNoiseCamera.transform;

            Camera @camera = fogWithNoiseCamera;

            Matrix4x4 fruscumCorner = Matrix4x4.identity;

            float near = @camera.nearClipPlane;

            float halfHeight = Mathf.Tan(@camera.fieldOfView / 2 * Mathf.Deg2Rad) * near;
            float halfWidth = halfHeight * @camera.aspect;

            Vector3 right = cameraTr.right * halfWidth;

            Vector3 top = cameraTr.up * halfHeight;

            Vector3 forward = cameraTr.forward * near;

            Vector3 topLeft = forward - right + top;
            Vector3 topRight = forward + right + top;
            Vector3 bottomLeft = forward - right - top;
            Vector3 bottomRight = forward + right - top;

            topLeft/=near;
            topRight/=near;
            bottomLeft/=near;
            bottomRight/=near;

            fruscumCorner.SetRow(0,bottomLeft);
            fruscumCorner.SetRow(1,bottomRight);
            fruscumCorner.SetRow(2,topRight);
            fruscumCorner.SetRow(3,topLeft);

            material.SetMatrix("_FruscumCorner",fruscumCorner);
            material.SetTexture("_FogNoise",fogNoise);
            material.SetColor("_FogColor",fogColor);
            material.SetFloat("_FogStart",fogStart);
            material.SetFloat("_FogEnd",fogEnd);
            material.SetFloat("_FogDensity",fogDensity);
            material.SetFloat("_NoiseAmount",noiseAmount);
            material.SetFloat("_SpeedX",speedX);
            material.SetFloat("_SpeedY",speedY);

            Graphics.Blit(src,dest,material);
        }
        else{
            Graphics.Blit(src,dest);
        }
   }
   protected override void OnDestroy()
   {
        base.OnDestroy();
        DestroyImmediate(material);
    
   }
}