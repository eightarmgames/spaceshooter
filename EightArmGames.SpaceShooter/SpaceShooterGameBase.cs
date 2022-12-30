using EightArmGames.SpaceShooter.Scenes;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Nez;

namespace EightArmGames.SpaceShooter
{
    public class SpaceShooterGameBase : Core
    {
        protected override void Initialize()
        {
            base.Initialize();

            Scene.SetDefaultDesignResolution(800, 600, Scene.SceneResolutionPolicy.ShowAllPixelPerfect);
            Screen.SetSize(800, 600);

            Scene = new GameScene();
        }
    }
}