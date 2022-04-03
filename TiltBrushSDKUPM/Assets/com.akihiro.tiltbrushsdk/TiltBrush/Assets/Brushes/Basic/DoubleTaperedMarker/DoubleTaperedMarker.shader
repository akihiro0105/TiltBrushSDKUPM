// Copyright 2017 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

Shader "Brush/Special/DoubleTaperedMarker" {
	Properties{
	}

	Category{
	  Cull Off Lighting Off

	  SubShader {
		Tags{ "DisableBatching" = "True" }
		Pass {

		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment frag
		  #pragma target 3.0
		  #pragma multi_compile_particles
		  #pragma multi_compile_fog
		  #pragma multi_compile __ TBT_LINEAR_TARGET

		  #include "UnityCG.cginc"
		  #include "../../../Shaders/Include/Brush.cginc"

		  sampler2D _MainTex;

		  struct appdata_t {
			float4 vertex : POSITION;
			fixed4 color : COLOR;
			float2 texcoord0 : TEXCOORD0;
			float3 texcoord1 : TEXCOORD1; //per vert offset vector

			UNITY_VERTEX_INPUT_INSTANCE_ID
		  };

		  struct v2f {
			float4 vertex : SV_POSITION;
			fixed4 color : COLOR;
			float2 texcoord : TEXCOORD0;
			UNITY_FOG_COORDS(1)

				UNITY_VERTEX_OUTPUT_STEREO
		  };

		  v2f vert(appdata_t v)
		  {

			  //
			  // XXX - THIS SHADER SHOULD BE DELETED AFTER WE TAPERING IS DONE IN THE GEOMETRY GENERATION
			  //

			  v2f o;

			  UNITY_SETUP_INSTANCE_ID(v);
			  UNITY_INITIALIZE_OUTPUT(v2f, o);
			  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

			  float envelope = sin(v.texcoord0.x * 3.14159);
			  float widthMultiplier = 1 - envelope;
			  v.vertex.xyz += -v.texcoord1 * widthMultiplier;
			  o.vertex = UnityObjectToClipPos(v.vertex);
			  o.color = TbVertToNative(v.color);
			  o.texcoord = v.texcoord0;
			  UNITY_TRANSFER_FOG(o, o.vertex);
			  return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{

				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

			  UNITY_APPLY_FOG(i.fogCoord, i.color.rgb);
			  return float4(i.color.rgb, 1);

			}

			ENDCG
		  }
		}
	}
}
