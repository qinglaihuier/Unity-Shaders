using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Stroke : PostEffectsBase
{
    [SerializeField] private Shader edgeDetectionShader;
    [SerializeField] private Material edgeDectionMat;

    [SerializeField,Range(0,1)] float edgeOnly;
    [SerializeField] Color edgeColor;
    [SerializeField] Color backgroundColor = Color.white;

    public Material material
    {
        get
        {
            edgeDectionMat = CheckShaderAndCreateMaterial(edgeDetectionShader, edgeDectionMat);
            return edgeDectionMat;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);  //这里如果删去会怎么样
        }
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        if (material != null)
            DestroyImmediate(material);
    }
    // Start is called before the first frame update

}
