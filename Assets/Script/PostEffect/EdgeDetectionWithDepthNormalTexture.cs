using System.Collections;
using System.Collections.Generic;
using UnityEngine;
class EdgeDetectionWithDepthNormalTexture : PostEffectsBase {
    [SerializeField] Shader edgeDetectionShader;
    Material edgeDetectionMaterial;
    public Material material{
        get{
            edgeDetectionMaterial = CheckShaderAndCreateMaterial(edgeDetectionShader,edgeDetectionMaterial);
            return edgeDetectionMaterial;
        }
    }
    [SerializeField,Range(0,1)] float edgeOnly = 1;
    [SerializeField] Color edgeColor;
    [SerializeField] Color backgroundColor = Color.white;
    [SerializeField] float sampleDistance = 1;
    [SerializeField] float sensityDepth = 1;
    [SerializeField] float sensityNomral = 1;

    Camera edgeDectionCamera;
    private void Awake() {
        edgeDectionCamera = GetComponent<Camera>();
    }
    private void OnEnable() {
        edgeDectionCamera.depthTextureMode|=DepthTextureMode.DepthNormals;
    }
    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if(material){
            material.SetFloat("_EdgeOnly",edgeOnly);
            material.SetColor("_EdgeColor",edgeColor);
            material.SetColor("_BackgroundColor",backgroundColor);
            material.SetFloat("_SampleDistance",sampleDistance);
            material.SetVector("_SampleSensity",new Vector4(sensityDepth,sensityNomral,0,0));

            Graphics.Blit(src,dest,material);
        }
        else{
            Graphics.Blit(src,dest);
        }
    }
    protected override void OnDestroy(){
        base.OnDestroy();
        DestroyImmediate(material);
    }

}