using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    [SerializeField] private Shader GaussianBlurShader;
    private Material GaussianBlurMat;

    [SerializeField, Range(0, 10)] private int blurSize = 1;

    [SerializeField] private int blurCount;

    [SerializeField] private int downSample = 2;

    public Material material
    {
        get
        {
            GaussianBlurMat = CheckShaderAndCreateMaterial(GaussianBlurShader, GaussianBlurMat);
            return GaussianBlurMat;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            material.SetFloat("_BlurSize", blurSize);
            int width = source.width;
            int height = source.height;

            RenderTexture buffer0 = RenderTexture.GetTemporary(width / downSample, height / downSample, 0);

            buffer0.filterMode = FilterMode.Bilinear;
          
            Graphics.Blit(source, buffer0);

            for (int i = 0; i < blurCount; ++i)
            {
                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);

                Graphics.Blit(buffer0, buffer1, material, 0);

                buffer0.Release();

                buffer0 = buffer1;

                buffer1 = RenderTexture.GetTemporary(width, height,0);

                Graphics.Blit(buffer0, buffer1, material, 1);

                buffer0.Release();

                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0, destination);

            buffer0.Release();
        }
        else
        {
            Graphics.Blit(source, destination);
            Debug.Log("material is null");
        }
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        if (material != null)
        {
            DestroyImmediate(material);
        }
    }
}
