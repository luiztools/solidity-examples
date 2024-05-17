// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract OtimizacoesLogicas {
    uint x = 0;

    function multiplasEscritas() external {
        for (uint i = 0; i < 10; i++) x += i;
    }

    function umaEscrita() external {
        uint local = 0;
        for (uint i = 0; i < 10; i++) local += i;
        x = local;
    }

    uint y = 0;
    function multiplasLeituras() external {
        for (uint i = 0; i < 10; i++) {
            if (y > 0) y = 1;
        }
        x = 1;
    }

    function umaLeitura() external {
        uint local = y;
        for (uint i = 0; i < 10; i++) {
            if (local > 0) y = 1;
        }
        x = 1;
    }
}
