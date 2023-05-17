using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectsBase
{
    [SerializeField] Shader shader;

    Material motionBlurWithDepthTexMat;

    public Material material
    {
        get
        {
            motionBlurWithDepthTexMat = CheckShaderAndCreateMaterial(shader, motionBlurWithDepthTexMat);

            return motionBlurWithDepthTexMat;
        }
    }

    [SerializeField,Range(0,1)] float blurSize = 0.5f;

    Matrix4x4 previousViewProjection;

    Matrix4x4 currentViewProjection;

    Camera heCamera;

    Camera TheCamera
    {
        get
        {
            if (heCamera == null)
            {
                heCamera = GetComponent<Camera>();
            }
            return heCamera;
        }
    }
   

    private void OnEnable()
    {
        TheCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null) {
            material.SetFloat("_BlurSize", blurSize);

            currentViewProjection = TheCamera.worldToCameraMatrix * TheCamera.projectionMatrix;

            if (previousViewProjection == null)
            {
                previousViewProjection = currentViewProjection;
            }

            material.SetMatrix("_PreviousViewProjection", previousViewProjection);

            material.SetMatrix("_CurrentViewProjectionInverse", currentViewProjection.inverse);

            Graphics.Blit(source, destination, material);

            previousViewProjection = currentViewProjection;
        }
        else
        {
            Graphics.Blit(source, destination, material);
        }
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        DestroyImmediate(material);
    }
    // Start is called before the first frame update

}
