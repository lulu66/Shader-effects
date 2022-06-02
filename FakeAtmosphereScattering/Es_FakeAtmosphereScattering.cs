using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class Es_FakeAtmosphereScattering : MonoBehaviour
{
	//public Camera MainCamera;
	private Material FakeAtmosphereScatteriMaterial;
	private void OnEnable()
	{
		if(FakeAtmosphereScatteriMaterial == null)
		{
			FakeAtmosphereScatteriMaterial = transform.GetComponent<MeshRenderer>().sharedMaterial;
		}
        if (FakeAtmosphereScatteriMaterial)
        {
			FakeAtmosphereScatteriMaterial.SetInt("_Mode", 1);
			FakeAtmosphereScatteriMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
			FakeAtmosphereScatteriMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
		}
        else
        {
			Debug.LogError($"{gameObject.name}上并未找到Material！");
        }
	}

	private void OnDisable()
	{
	}


}
