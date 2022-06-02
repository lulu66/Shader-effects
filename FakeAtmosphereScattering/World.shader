Shader "Unlit/World"
{
	Properties
	{
		_Color("Color",Color) = (0,0,1,1)
		_FresnelPower("Fresnel Power", Range(0,20)) = 20

	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
            };

			half4 _Color;
			float _FresnelPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldPos = worldPos;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = normalize(worldNormal);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color;
				
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 normalDir = normalize(i.worldNormal);
				//fresnel
				half fresnel = pow(1 - saturate(dot(viewDir, normalDir)), _FresnelPower);
				fresnel = saturate(fresnel);
				half alpha = smoothstep(0.4, 0.7, 1-fresnel);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
				col.a = alpha;
                return col;
            }
            ENDCG
        }
    }
}
