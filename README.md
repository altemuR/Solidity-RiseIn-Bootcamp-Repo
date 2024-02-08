# Solidity-RiseIn-Bootcamp-Repo

## The Final Project
This repository is the submission for the Rise In Solidity Bootcamp Final Project.

The final smart contract is deployed on the Sepolia Testnet and the contract address is: 
0x39690761170a39832B267Ac679A7fe2a30295699

[Contract Link](https://sepolia.etherscan.io/address/0x39690761170a39832b267ac679a7fe2a30295699#code)

*This is the updated  address and it might be different from the one submitted on the Rise-in dashboard (Had some trouble editing the address on the dashboard)

## Table of Contents

- [Overview](#overview)
- [Features](#features)

## Overview

A proposal smart contract for voting purposes.

## Features

- Creation of Proposals with a title, description, approve, reject & pass voting capabilities as well as monitoring current status.
- Custom Functions & modifiers include:
- Prerequisites for changing contract owner(eg. Can't be the new owner if vote is already cast)
- Checks implemented so there is only one proposal active at any given time
- Minimum number of votes variable added for all contracts
- New Function: getNumberOfVotesCastForActiveProposal(): Can get the number of votes cast for the active proposal
- New Function: getOwner(): Returns the address of the owner
- New Function: amIOwner(): Returns true/false if the sender address is the owner
- New Function: haveIVoted() : Returns true/false according to the current status
- New Function: activeProposalTitle() : A function that returns the active proposal title
- New Function: totalNumberOfProposals() : A function that returns the total number of proposals
- New Function: numberOfMinimumVotesRequired() : A function that returns the number of minimum votes required for all new proposals.

