// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./libraries/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

contract MyEpicGame is ERC721 {

  struct SpellAttributes {
    uint spellIndex;
    string name;
    string imageURI;
    uint concentration;
    uint maxConcentration;
    uint attackDamage;
  }

  struct PlayerStats {
    address playerAddress;
    uint256 playerScore;
  }

  address public owner;

  using Counters for Counters.Counter;
  Counters.Counter public _tokenIds;

  SpellAttributes[] public defaultSpells;
  PlayerStats[] allPlayers;

  mapping(uint256 => SpellAttributes) public nftHolderAttributes;
  mapping(address => uint256) public nftHolders;

  event SpellNFTMinted(address sender, uint256 tokenId, uint256 spellIndex);
  event AttackComplete(uint newBossHp, uint newPlayerConcentration);

  struct BBEG {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  BBEG public bigBoss;

  constructor(
    string[] memory spellNames,
    string[] memory spellImageURIs,
    uint[] memory spellConcentration,
    uint[] memory spellAttackDmg,
    string memory bossName,
    string memory bossImageURI,
    uint bossHp,
    uint bossAttackDamage
    ) ERC721("Spells", "SPELL") {

    owner = msg.sender;

    bigBoss = BBEG({
      name: bossName,
      imageURI: bossImageURI,
      hp: bossHp,
      maxHp: bossHp,
      attackDamage: bossAttackDamage
    });

    console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);
    
    for(uint i = 0; i < spellNames.length; i += 1){
      defaultSpells.push(SpellAttributes({
        spellIndex: i,
        name: spellNames[i],
        imageURI: spellImageURIs[i],
        concentration: spellConcentration[i],
        maxConcentration: spellConcentration[i],
        attackDamage: spellAttackDmg[i]
      }));

      SpellAttributes memory c = defaultSpells[i];
      console.log("Done initializing %s w/ Concentration %s, img %s", c.name, c.concentration, c.imageURI);
    }

    _tokenIds.increment(); // To ensure the first tokenId is not 0
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    SpellAttributes memory sAttributes = nftHolderAttributes[_tokenId];

    string memory strConcentration = Strings.toString(sAttributes.concentration);
    string memory strMaxConcentration = Strings.toString(sAttributes.maxConcentration);
    string memory strAttackDamage = Strings.toString(sAttributes.attackDamage);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            sAttributes.name,
            ' -- NFT #: ',
            Strings.toString(_tokenId),
            '", "description": "This is an NFT that lets people play in the game Metaverse Mage!", "image": "ipfs://',
            sAttributes.imageURI,
            '", "attributes": [ { "trait_type": "Concentration", "value": ', strConcentration,', "max_value":', strMaxConcentration,'}, { "trait_type": "Attack Damage", "value": ', strAttackDamage, '} ]}'
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return output;
  }

  function mintSpellNFT(uint _spellIndex) external {
    uint256 newItemId = _tokenIds.current();
    require(!checkIfPlayer());

    _safeMint(msg.sender, newItemId);

    nftHolderAttributes[newItemId] = SpellAttributes({
      spellIndex: _spellIndex,
      name: defaultSpells[_spellIndex].name,
      imageURI: defaultSpells[_spellIndex].imageURI,
      concentration: defaultSpells[_spellIndex].concentration,
      maxConcentration: defaultSpells[_spellIndex].maxConcentration,
      attackDamage: defaultSpells[_spellIndex].attackDamage
    });

    console.log("Minted NFT w/ tokenId %s and spellIndex %s", newItemId, _spellIndex);

    nftHolders[msg.sender] = newItemId;
    PlayerStats memory player = PlayerStats({
      playerAddress: msg.sender,
      playerScore: 0
    });
    allPlayers.push(player);

    _tokenIds.increment();

    emit SpellNFTMinted(msg.sender, newItemId, _spellIndex);
  }

  function attackBoss() public {
    //Get the state of the player's NFT.
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    SpellAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
    console.log("\nPlayer w/ spell %s about to attack. Has %s Concentration and %s AD", player.name, player.concentration, player.attackDamage);
    console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

    require(
      player.concentration > 0,
      "Error: Character must have concentration to cast a spell."
    );

    require(
      bigBoss.hp > 0,
      "Error: boss must have HP to attack boss."
    );

    // Allow player to attack boss.
    if (bigBoss.hp < player.attackDamage) {
      bigBoss.hp = 0;
    } else {
      bigBoss.hp = bigBoss.hp - player.attackDamage;
    }
    console.log("Player attacked Boss. New Boss hp: %s", bigBoss.hp);

    // Allow boss to attack player.
    if (player.concentration < bigBoss.attackDamage) {
      player.concentration = 0;
    } else {
      player.concentration = player.concentration - bigBoss.attackDamage;
    }

    console.log("Boss attacked player. New player concentration: %s\n", player.concentration);

    
    emit AttackComplete(bigBoss.hp, player.concentration);
  }

  function checkIfUserHasNFT() public view returns (SpellAttributes memory) {
    // Get the tokenId of the user's spell NFT
    uint256 userNftTokenId = nftHolders[msg.sender];
    // If the user has a tokenId in the map, return their spell.
    if (userNftTokenId > 0) {
      return nftHolderAttributes[userNftTokenId];
    }
    // Else, return an empty spell.
    else {
      SpellAttributes memory emptyStruct;
      return emptyStruct;
    }
  }

  function checkIfPlayer() public view returns (bool) {
    // Get the tokenId of the user's spell NFT
    uint256 userNftTokenId = nftHolders[msg.sender];
    // If the user has a tokenId in the map he is a player, return true
    if (userNftTokenId > 0) {
      return true;
    }
    // Else, return false
    else {
      return false;
    }
  }

  function getAllDefaultSpells() public view returns (SpellAttributes[] memory){
    return defaultSpells;
  }

  function getBigBoss() public view returns (BBEG memory) {
    return bigBoss;
  }

  function getAllPlayers() public view returns (PlayerStats[] memory){
    return allPlayers;
  }

}