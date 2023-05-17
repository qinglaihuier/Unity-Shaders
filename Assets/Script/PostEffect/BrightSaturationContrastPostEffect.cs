using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightSaturationContrastPostEffect : PostEffectsBase
{
    [Range(0, 3)]
    public float bright = 1;
    [Range(0, 100)]
    public float saturation = 1;
    [Range(0, 3)]
    public float contrast = 1;
    // Start is called before the first frame update

    [SerializeField]
    private Shader shader;
    private Material _material;
    public Material material
    {
        get
        {
            _material = CheckShaderAndCreateMaterial(shader, _material);
            return _material;
        }
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_Bright", bright);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
            Debug.Log("Material is null");
        }
    }
    protected override void OnDestroy()
    {
        base.OnDestroy();
        if(material!=null)
            DestroyImmediate(material);
    }
}
