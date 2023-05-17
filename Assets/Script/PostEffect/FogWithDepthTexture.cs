using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithDepthTexture : PostEffectsBase
{
    [SerializeField] Shader fogShader;
    [SerializeField] Material fogMaterial;
    public Material material{
        get{
            fogMaterial = CheckShaderAndCreateMaterial(fogShader,fogMaterial);
            return fogMaterial;
        }
    }
    Camera fogCamera;
    private void Awake() {
        fogCamera = GetComponent<Camera>();
        fogCamera.depthTextureMode|=DepthTextureMode.Depth;
    }
    [SerializeField]Color fogColor;
    [SerializeField]float fogDestiny;
    [SerializeField]float fogStartHeight;
    [SerializeField]float fogEndHeight;
    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if(material){
            Matrix4x4 frustumCorner = Matrix4x4.identity;

            Transform cameraTransform = fogCamera.transform;

            material.SetColor("_FogColor",fogColor);
            material.SetFloat("_FogDestiny",fogDestiny);
            material.SetFloat("_FogStartHeight",fogStartHeight);
            material.SetFloat("_FogEndHeight",fogEndHeight);

            float fov = fogCamera.fieldOfView;
            float near = fogCamera.nearClipPlane;
            float far = fogCamera.farClipPlane;
            float aspect = fogCamera.aspect;

            float halfHeight = near * Mathf.Tan(fov/2*Mathf.Deg2Rad);
            float halfWidth = halfHeight * aspect;

            Vector3 top = cameraTransform.up * halfHeight;
            Vector3 right = cameraTransform.right * halfWidth;

            Vector3 topleft = cameraTransform.forward * near + top - right;
            topleft/=near;

            Vector3 topRight = cameraTransform.forward * near + top + right;
            topRight /=near;

            Vector3 bottomLeft = cameraTransform.forward * near - top - right;
            bottomLeft/=near;

            Vector3 bottomRight = cameraTransform.forward * near - top + right;
            bottomRight/=near;

            frustumCorner.SetRow(0,topleft);
            frustumCorner.SetRow(1,topRight);
            frustumCorner.SetRow(2,bottomLeft);
            frustumCorner.SetRow(3,bottomRight);

            material.SetMatrix("_FrustumCorner",frustumCorner);

            Graphics.Blit(src,dest,material);
        }
        else{
            Graphics.Blit(src,dest,material);
        }
    }

    protected override void OnDestroy(){
        base.OnDestroy();
        DestroyImmediate(material);
    }
}
