using UnityEngine;

namespace TessellationDemo
{
    public class MaterialUpdater : MonoBehaviour
    {
        [SerializeField]
        protected MeshRenderer _renderer;
        
        public void UpdateGridSize(float value)
        {
            _renderer.material.SetFloat("_GridSize", value);
        }

        public void UpdateAngle(float value)
        {
            _renderer.material.SetFloat("_AngleOffset", value);
        }

        public void UpdateTexture(Texture2D tex)
        {
            _renderer.material.SetTexture("_Texture", tex);
        }
    }
}
