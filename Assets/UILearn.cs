using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
public class UILearn : MonoBehaviour,IPointerClickHandler
{
    [SerializeField]RectTransform rect;

    // Start is called before the first frame update
    void Start()
    {
       
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void OnPointerClick(PointerEventData eventData)
    {
        Vector3 pos = Vector3.zero;
        Debug.Log("asdasdas");
       if(RectTransformUtility.ScreenPointToWorldPointInRectangle(
           rect,eventData.position,eventData.enterEventCamera,out pos
           ) == true)
        {
            if (eventData.enterEventCamera == null)
            {
                Debug.Log(null);
            }
            Debug.Log(pos);
            Debug.Log(eventData.position);
            Debug.Log(true);
        }
        else
        {
            Debug.Log(pos);
            Debug.Log("false");
        }
    }
}
