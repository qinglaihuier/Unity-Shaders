using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectsBase
{
    [SerializeField] Shader motionBlurShader;
     Material motionBlurMaterial;
    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    RenderTexture accumulationTexture;

    [SerializeField, Range(0.1f, 0.9f)] float blurSize;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            if(accumulationTexture==null || accumulationTexture.width!=source.width 
                || accumulationTexture.height != source.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = RenderTexture.GetTemporary(source.width, source.height);
                accumulationTexture.hideFlags = HideFlags.DontSave;
                Graphics.Blit(source, accumulationTexture);
            }

            accumulationTexture.MarkRestoreExpected();

            material.SetFloat("_BlurSize", 1- blurSize);

            Graphics.Blit(source, accumulationTexture, material);

            Graphics.Blit(accumulationTexture, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    private void OnDisable()
    {
        DestroyImmediate(accumulationTexture);
    }
    protected override void OnDestroy()
    {
        base.OnDestroy();
        if(material!=null)
            DestroyImmediate(material);
    }

}
