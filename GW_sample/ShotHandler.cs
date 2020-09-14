using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShotHandler : MonoBehaviour
{

    UIHandler uiHandler;



    [HideInInspector]
    public bool canFire;

    // vegetable's actions
    public Action OnPeaShoot;
    public Action OnChilliShoot;
    public Action OnChestnutShoot;
    public Action OnMeshedPotatoesRayShoot;
    public Action OnCornShoot;
    public Action OnOnionShoot;
    public Action OnPumpkinShoot;

    // friut's actions
    public Action OnCherryShoot;
    public Action OnBlueberryShoot;
    public Action OnLemonShoot;
    public Action OnWineRayShoot;
    public Action OnWatermelonShoot;
    public Action OnBananaShoot;
    public Action OnDurianShoot;

    public Action OnVacuumCleanerShoot;


    PlayerController pc;

    public GameObject[] allGuns;

    [HideInInspector]
    public GameObject[] availableGuns;
    [HideInInspector]
    public Gun[] gAvailableGuns;



    //execution order set to be before PlayerController's Awake()
    private void Awake()
    {
        uiHandler = this.GetComponent<UIHandler>();
        pc = this.GetComponent<PlayerController>();
        pc.shotHandler = this;

        availableGuns = new GameObject[4];
        gAvailableGuns = new Gun[4];

        

        pc.infoHolder = GameObject.FindGameObjectWithTag("InfoHolder")?.GetComponent<InfoHolder>();
        if (pc.infoHolder == null)
            pc.infoHolder = new GameObject().AddComponent<InfoHolder>();

        if (pc.infoHolder.gameMode == InfoHolder.GameMode.Vegetable)
        {
            

            availableGuns[0] = Instantiate<GameObject>(FindGunByName(PlayerController.GUNS.PeaGun.ToString()), pc.GetEmptyObjPlace());
            availableGuns[3] = Instantiate<GameObject>(FindGunByName(PlayerController.GUNS.ChilliGun.ToString()), pc.GetEmptyObjPlace());
            availableGuns[1] = Instantiate<GameObject>(FindGunByName(PlayerController.GUNS.MeshedPotatoesGun.ToString()), pc.GetEmptyObjPlace());
            availableGuns[2] = Instantiate<GameObject>(FindGunByName(PlayerController.GUNS.ChestnutGun.ToString()), pc.GetEmptyObjPlace());

            for (int i = 0; i < availableGuns.Length; i++)
            {
                gAvailableGuns[i] = availableGuns[i].GetComponent<Gun>();
            }

            AsignGunBehavior();

            pc.OnShootGunOne = OnPeaShoot;
            pc.OnShootGunFour = OnChilliShoot;
            pc.OnShootGunTwo = OnMeshedPotatoesRayShoot;
            pc.OnShootGunThree = OnChestnutShoot;
            //OnShootGunFour = OnVacuumCleanerShoot;


        }
/*        else
        {
            OnShootGunOne = shotHandler.OnCherryShoot;
            OnShootGunTwo = shotHandler.OnBlueberryShoot;
            //OnShootGunThree = OnLemonShoot;
            OnShootGunThree = shotHandler.OnWatermelonShoot;
            OnShootGunFour = shotHandler.OnVacuumCleanerShoot;

            availableGuns[0] = FindGunByName(GUNS.CherryGun.ToString());
            availableGuns[1] = FindGunByName(GUNS.BlueberryGun.ToString());
            //availableGuns[2] = FindGunByName("LemonGun");
            availableGuns[2] = FindGunByName(GUNS.WatermelonGun.ToString());
            availableGuns[3] = FindGunByName(GUNS.VacuumCleanerGun.ToString());
        }*/

        

        pc.SetCurrentGun(0);        
    }

    private GameObject FindGunByName(String name)
    {
        foreach (GameObject go in allGuns)
        {
            if (go.name.Equals(name))
                return go;
        }

        return null;
    }



    private void FixedUpdate()
    {
        foreach (Gun g in gAvailableGuns)
        {
            g.HandleFireTiming();
        }
    }




    public void AsignGunBehavior()
    {

        foreach (Gun g in gAvailableGuns)
        {
            if (g.name == $"{PlayerController.GUNS.PeaGun}(Clone)")
            {
                OnPeaShoot += g.Shoot;
            }
            else if (g.name == $"{PlayerController.GUNS.ChilliGun}(Clone)")
            {
                OnChilliShoot += g.Shoot;
            }
            else if (g.name == $"{PlayerController.GUNS.ChestnutGun}(Clone)")
            {
                OnChestnutShoot += g.Shoot;
            }


        }
    }





 /*   private void ShootRay()
    {
        Ray2D ray = new Ray2D(origin: spawnPositions[0].position, direction: pc.GetEmptyObjPlace().rotation.eulerAngles);
        Debug.Log("im in here");
        Debug.Log(pc.GetEmptyObjPlace().rotation.eulerAngles);
        Debug.DrawRay(spawnPositions[0].position, uiHandler.GetRightStick().GetComponent<RectTransform>().anchoredPosition, Color.red, 1f);

        
    }*/
}
