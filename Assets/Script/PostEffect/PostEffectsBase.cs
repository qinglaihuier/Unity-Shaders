using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    Material material;
    private void Awake()
    {
        Debug.Log("Post Effect Base Awake");
    }
    protected virtual void Start()
    {
        CheckResource();
    }
    protected virtual void CheckResource()
    {
        bool isSupport = CheckSupport();

        if (!isSupport)
        {
            NotSupport();
        }
    }
    protected virtual bool CheckSupport()
    {
        // if(SystemInfo.supportsImageEffects==false || SystemInfo.supportsRenderTextures == false)
        // {
        //     Debug.LogWarning("不支持");
        //     return false;
        // }

        return true;
    }
    protected virtual void NotSupport()
    {
        enabled = false;
    }
    protected Material CheckShaderAndCreateMaterial(Shader shader,Material material)
    {
        if (shader == null)
        {
            return null;
        }
        if (shader.isSupported == false)
        {
            Debug.LogWarning("Shader is not Supported");
            return null;
        }
        if (shader.isSupported && material && material.shader == shader)
        {
            return material;
        }
        if (shader.isSupported && material && material.shader != shader)
        {
            material.shader = shader;
            return material;
        }
        else
        {
            Debug.Log("Create Material");
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
            {
                return material;
            }
            else
            {
                return null;
            }
         
        }
    }
    protected virtual void OnDestroy()
    {
        Debug.Log("Post Effect Base Destroy");
    }
}