#!/bin/bash
# BashChain v0.1a : BASH Blockchain PoC : https://github.com/elemantalcode/bash-scripts

# Set some basic blockchain variables
difficulty=1                         # Set the difficulty of "mining". Set to < 3 for testing and > 20 to burn CPU cycles
genesis_time="2017-01-01 00:00:00"   # Set the Genesis block time
genesis_data="Genesis Block"         # Set the Genesis block data
chain_count=6                        # Amount of blocks to generate

# Standard variables
nonce=0                              # Always start with 0 nonce
blockchain=()                        # Declare our blockchain array variable
chain_increment=1                    # Start increment from 1 because Genesis = 0

function genBlock() {                # Generate a block
        block_index="$1"                 # Block index number
        block_previous="$2"              # Previous block
        block_timestamp="$3"             # Timestamp for the block
        block_data="$4"                  # Data to preserve in block

        [[ "$2" == "genesis" ]] && block_previous=$'\0'  # If Genesis, set to explicit NULL
        [[ "$3" == "now" ]] && block_timestamp="${now}"  # Use current timestamp unless otherwise told

        # Send off to calculate the hash
        newblock=$( getHash "${block_index}" "${block_previous}" "${block_timestamp}" "${block_data}" "${nonce}" )
        echo "${newblock}"               # Return the new block
}

function getHash() {                 # Calculate the HASH (we use SHA256)
        hash_index="$1"                  # Hash index number
        hash_previous="$2"               # Previous hash
        hash_timestamp="$3"              # Timestamp for the hash
        hash_data="$4"                   # Data to preserve as part of hash
        hash_nonce="$5"                  # NONCEnse :P

        # Use existing Linux tools and strip out unwanted output
        hash_256=$( echo "${hash_index}${hash_previous}${hash_timestamp}${hash_data}${hash_nonce}" | sha256sum | awk '{print $1}' )
        echo "${hash_256}"               # Return the new hash
}

function getGenesis() {              # In the beginning... Genesis 1:1
        genesis_time="$1"                # Timestamp for the Genesis block
        genesis_data="$2"                # Data to use as part of the Genesis block

        # Generate the Genesis block in the same way that we mine other blocks, with different values though
        genesis=$( genBlock "0" "genesis" "${genesis_time}" "${genesis_data}" "${nonce}" )
        echo "${genesis}"                # Return the Genesis block
}

function mineBlock() {
        # This is terrible, I know, but shows extremely basic "proof of work" concept
        # For the love of green apples and all that is holy, do NOT use in production... no, seriously!
        mine_index="$1"                  # Index for the newly mined block
        mine_previous="$2"               # Previously mined block
        mine_data="$3"                   # Data to insert into mined block
        now=$( date '+%Y-%m-%d %H:%M:%S' ) # Current timestamp

        # So we generate a bunch of 0s to test against - the higher the difficulty, the more 0s
        a=$( printf -v row "%${difficulty}s"; echo ${row// /0} )
        b=""                             # Set an empty variable to test against

        while [ "$a" != "$b" ]           # So, while we haven't found the amount of 0s we want...
        do
                # Yup, "mine" a block
                mine_block=$( genBlock "$mine_index" "${mine_previous}" "${now}" "${mine_data}" "${nonce}" )
                b=${mine_block:0:$difficulty}  # Check for prefixed 0s and match against difficulty
                #echo "Trying HASH: $mine_block"
                (( nonce++ ))                # Increment nonce and try again
        done
        echo "${mine_block}"             # Return with our new shiny "mined" block
}

# Generate Genesis block
genesis=$( getGenesis "${genesis_time}" "${genesis_data}" )
# Add the block into the chain, as index 0. We use an array here; Could be a file, sql, whatever
blockchain[0]="IDX:0,TIME:${genesis_time},HASH:${genesis},DATA:${genesis_data}"

while [ $chain_increment -lt $chain_count ]  # Keep generating blocks and adding to chain until we reach
do                                           #  the requested limit
        # Grab the previous block in the chain, and strip out the HASH
        previous_block=$( echo "${blockchain[-1]}" | cut -d',' -f3 | cut -d':' -f2 )
        block_data="Block ${chain_increment}"    # Create "random" data for the blocks
        now=$( date '+%Y-%m-%d %H:%M:%S' )       # Current timestamp
        # Go forth and multiply (and add to your lineage... or at the very least, our blockchain array)
        newblock=$( mineBlock "${chain_increment}" "${previous_block}" "${block_data}" )
        blockchain[$chain_increment]="IDX:${chain_increment},TIME:${now},HASH:${newblock},DATA:${block_data}"
        (( chain_increment++ ))                  # Keep counting until we reach the requested block limit
done

OIFS="$IFS"                          # This is a naf cheat to avoid split lines on spaces
IFS="
"

for block in "${blockchain[@]}"      # Loop through every array entry (the blocks in the chain)
do
        echo "${block}"              # .....aaaaand display them ;)
done

# Reset IFS
IFS="$OIFS"
