# gbit_eth_switch


# Entity: mac_learner 
- **File**: mac_learner.vhd

## Diagram
![Diagram](mac_learner.svg "Diagram")
## Ports

| Port name | Direction | Type                           | Description |
| --------- | --------- | ------------------------------ | ----------- |
| clk       | in        | std_logic                      |             |
| reset     | in        | std_logic                      |             |
| saddress  | in        | std_logic_vector (47 downto 0) |             |
| daddress  | in        | std_logic_vector (47 downto 0) |             |
| portnum   | in        | std_logic_vector (2 downto 0)  |             |
| sel       | out       | std_logic_vector (2 downto 0)  |             |

## Instantiations

- SRAM_inst: SRAM

- **Bold Text**
- *Italicized Text*
- [Hyperlinks](https://www.example.com)
- ![Images](https://via.placeholder.com/150)
- `Code Snippets`
- > Blockquotes

### And don't forget about lists:

1. Ordered List Item 1
2. Ordered List Item 2
   - Sub-item A
   - Sub-item B
3. Ordered List Item 3

- Unordered List Item A
- Unordered List Item B
   - Sub-item i
   - Sub-item ii
- Unordered List Item C

### Tables can add structure:

| **Header 1** | **Header 2** | **Header 3** |
|--------------|--------------|--------------|
| Cell 1       | Cell 2       | Cell 3       |
| Cell 4       | Cell 5       | Cell 6       |
| Cell 7       | Cell 8       | Cell 9       |

### And finally, some code:
