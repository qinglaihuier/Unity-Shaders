using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class ProceduralTexGeneration : MonoBehaviour
{
    private Material material;
   
    [SerializeField, SetProperty("Texture_Width")]
    private int texture_width = 60;
    public int Texture_Width
    {
        get
        {
            return texture_width;
        }
        set
        {
            texture_width = value;
            UpdateMaterial();
        }
    }
    [SerializeField,SetProperty("Background_Color")]
    private Color _background_color = Color.black;
    public Color Background_Color
    {
        get
        {
            return _background_color;
        }
        set
        {
            _background_color = value;
            UpdateMaterial();
        }
    }
    [SerializeField, SetProperty(nameof(CircleColor))]
    private Color circleColor = Color.blue;
    public Color CircleColor
    {
        get
        {
            return circleColor;
        }
        set
        {
            circleColor = value;
            UpdateMaterial();
        }
    }
    [SerializeField,SetProperty(nameof(BlurFactor))]
    private float blurFactor;
    public float BlurFactor
    {
        get
        {
            return blurFactor;
        }
        set
        {
            blurFactor = value;
            UpdateMaterial();
        }
    }

    Texture2D texture ;
    private void Start()
    {
       
        if (material == null)
        {
            Renderer render = GetComponent<Renderer>();

            material = render.sharedMaterial;

            material.SetTexture("_MainTex", texture);
        }
        UpdateMaterial();
    }

    void UpdateMaterial()
    {
        if (texture == null)
        {
            texture = new Texture2D(texture_width, texture_width);
        }
        GenerateTexture(texture);
        material.SetTexture("_MainTex", texture);
    }
    void GenerateTexture(Texture2D texture)
    {
        float radius = texture_width / 10;
        float blur = 1 / BlurFactor;
        float interval = texture_width / 4;

        Color pixelColor = Color.white;

        for (int w = 0; w < texture_width; ++w)
        {
            for(int h = 0; h < texture_width; ++h)
            {
                pixelColor = Background_Color;

                for (int i = 0; i < 3; ++i)
                {
                    for(int j = 0; j < 3; ++j)
                    {
                      

                        Vector2 circleCenter = new Vector2((i + 1) * interval, (j + 1) * interval);

                        float distance = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

                        Color color = MixColor(circleColor, new Color(pixelColor.r, pixelColor.g, pixelColor.b, 0), Mathf.SmoothStep(0,1,distance*blur));

                        pixelColor = MixColor(pixelColor, color, color.a);

                    }
                }
                texture.SetPixel(w, h, pixelColor);
            }
        }
        texture.Apply();
    }
   Color MixColor(Color c0,Color c1,float a)
   {
        Color result = Color.white;

        result.r = Mathf.Lerp(c0.r, c1.r, a);
        result.g = Mathf.Lerp(c0.g, c1.g, a);
        result.b = Mathf.Lerp(c0.b, c1.b, a);
        result.a = Mathf.Lerp(c0.a, c1.a, a);

        return result;
   }
    
}
