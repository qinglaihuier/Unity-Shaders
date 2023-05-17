using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class Bloom : PostEffectsBase
{
    [SerializeField] Shader bloomShader;
    Material bloomMaterial;

    [SerializeField, Range(0, 10)] int iterations = 2;

    [SerializeField, Range(0, 10)] float blurSpread = 1;

    [SerializeField] int downSample = 2;  //²»Òª³ýÒÔ0

    [SerializeField, Range(0, 3)] float luminanceThreshold = 0.6f;
    
    public Material material
    {
        get
        {
            bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            return bloomMaterial;
        }
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int width = source.width / downSample;
            int height = source.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);

            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, buffer0, material, 0);

            for(int i = 0; i < iterations; ++i)
            {
                material.SetFloat("_BlurSize", 1 + blurSpread * i);

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height);

                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);

                buffer0 = buffer1;

                buffer1 = RenderTexture.GetTemporary(width, height);

                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);

                buffer0 = buffer1;
            }
            material.SetTexture("_Bloom", buffer0);

            Graphics.Blit(source, destination, material, 3);

            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
    protected override void OnDestroy()
    {
        base.OnDestroy();
        if (material)
        {
            DestroyImmediate(material);
        }
    }

}
