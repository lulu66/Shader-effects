Shader "EsShaders/EsShaders_FakeAtmosphereScattering"
{
    Properties
    {
		[HDR]_LightingColor("Lighting Color", Color) = (1,1,1,1)
		_LightingFallOff("Lighting Fall Off", Range(0.01, 10)) = 1
		_LightingStrength("Lighting Strength", Range(0.01,0.99)) = 0.01
	}
		SubShader
		{
			Tags
			{
				 "Queue" = "Transparent-100" "IgnoreProjector" = "True"
			}

			CGINCLUDE
			//--------------------------------------------------------------------------------------------
			// Downsample, bilateral blur and upsample config
			//--------------------------------------------------------------------------------------------        
			#define PI 3.1415927f

			#include "UnityCG.cginc"	
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D  _MatCap;

			float _LightingFallOff;
			half _LightingStrength;
			fixed4 _LightingColor;
			int _Mode;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 localPos : TEXCOORD1;
				float3 worldPos: TEXCOORD4;
				float2 vNormal : TEXCOORD2;
			};


			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.localPos = v.vertex;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				half3 vNormal = normalize(mul(UNITY_MATRIX_IT_MV, float4(-v.normal,0.0)).xyz);
				//o.vNormal = vNormal.xy * 0.5 + 0.5;
				return o;
			}

			inline float sphereSdfFallOff(float3 ro, float3 rd, float ra/*, float sceneDepth*/)
			{
				float b = dot(ro, rd);
				float c = dot(ro, ro) - ra * ra;
				float h = b * b - c;
				if (h < 0.0) return 0; // no intersection
				h = sqrt(h);
				float2 sdf = float2(-b - h, -b + h);
				//sdf.x = max(0, sdf.x);
				//sdf.y = min(sceneDepth, sdf.y);
				float3 intersectionPos = ro + rd * (sdf.x + sdf.y) * 0.5;

				float alpha = smoothstep(1, _LightingStrength, length(intersectionPos) / ra );
				alpha = pow(alpha, _LightingFallOff);
				return alpha;
			}

			fixed4 outputColor(half alpha)
			{
				return fixed4(_LightingColor.rgb * alpha, alpha);
			}

			ENDCG

				// pass 0 - sphere shape.
			Pass
			{

				Blend One OneMinusSrcAlpha
				Lighting Off
				Cull Off
				ZWrite Off
				//ZTest Always
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment shapeFrag
				#pragma target 3.0


				fixed4 shapeFrag(v2f i) : SV_Target
				{
					float3 cameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
					float3 cameraDir = normalize(i.localPos.xyz - cameraPos);
					float alpha = sphereSdfFallOff(cameraPos, cameraDir, 1.0/*, sceneDepth*/);
					return outputColor(alpha);
				}
				ENDCG
			}
    }
}
